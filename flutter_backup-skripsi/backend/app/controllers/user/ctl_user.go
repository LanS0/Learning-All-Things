package user

import (
	"backend/app/controllers/common"
	"backend/app/models"
	"backend/database"
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

func hashPassword(password string) (string, error) {
	hashedBytes, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	return string(hashedBytes), err
}

func checkPassword(hashedPassword, inputPassword string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(inputPassword))
	return err == nil
}

func encryptData(db *gorm.DB, data string, key string) ([]byte, error) {
	var encryptedData []byte
	err := db.Raw("SELECT pgp_sym_encrypt(?, ?)", data, key).Row().Scan(&encryptedData)
	if err != nil {
		return []byte("hai"), err
	}

	return encryptedData, nil
}

// GET User
// @Summary GET User
// @Description GET User
// @Tags User
// @Accept json
// @Produce json
// @Param data body interface{} true "Object data"
// @Success 200 {object} interface{}
// @Router /api/user/ [post]
// @Security ApiKeyAuth
func Login(c *fiber.Ctx) error {
	dataUser := new(models.InsertUser)
	if err := c.BodyParser(&dataUser); err != nil {
		return c.JSON(fiber.Map{
			"Statuc Code ": c.Response().Header.StatusCode(),
			"Message":      err,
			"Data":         nil,
		})
	}

	db := database.DBCon
	sKey := common.SECRET

	sWhere := ` WHERE u.deleted_at IS NULL AND (pgp_sym_decrypt("email", ?) = '` + dataUser.Email + `' OR pgp_sym_decrypt("name", ?) = '` + dataUser.Email + `') `

	sqlQuery := `
		SELECT 
		u.*,
		pgp_sym_decrypt("name", ?) name,
		pgp_sym_decrypt("email", ?) email
		FROM users u
		` + sWhere + `
	`

	var user models.Users
	result := db.Raw(sqlQuery, sKey, sKey, sKey, sKey).Find(&user)
	if result.Error == gorm.ErrRecordNotFound {
		// ResultData(nil, "user tidak ditemukan")
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-02",
			Message:    "email or username not found",
			Data:       make(map[string]string, 1),
		})
	} else if result.Error != nil {
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-02",
			Message:    "error",
			Data:       make(map[string]string, 1),
		})
	}

	if !checkPassword(user.Password, dataUser.Password) {
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-02",
			Message:    "wrong email / username or password",
			Data:       make(map[string]string, 1),
		})
	}

	datas := models.ReturnUser{
		ID:       user.ID,
		Name:     user.Name,
		Email:    user.Email,
		IsVIP:    user.IsVIP,
		Favorite: user.Favorite,
		Like:     user.Like,
	}

	exp, _ := strconv.Atoi(common.JwtExpiredIn)

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": user.ID,
		"sub":     user.Email,
		"exp":     time.Now().Add(time.Minute * time.Duration(exp)).Unix(),
	})

	tokenString, err := token.SignedString([]byte(common.JwtSecret))

	if err != nil {
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-05",
			Message:    fmt.Sprintf("generating JWT Token failed: %v", err),
			Data:       make([]string, 0),
		})
	}

	return c.Status(fiber.StatusOK).JSON(models.ResultLogin{
		StatusCode: "EYZ-01",
		Message:    "success",
		Data:       datas,
		Token:      tokenString,
	})
}

// Insert User
// @Summary Insert User
// @Description Insert User
// @Tags User
// @Accept json
// @Produce json
// @Param data body interface{} true "Object data"
// @Success 200 {object} interface{}
// @Router /api/user [post]
// @Security ApiKeyAuth
func Register(c *fiber.Ctx) error {
	dataUser := new(models.InsertUser)
	if err := c.BodyParser(&dataUser); err != nil {
		return c.JSON(fiber.Map{
			"Statuc Code ": c.Response().Header.StatusCode(),
			"Message":      err,
			"Data":         nil,
		})
	}

	db := database.DBCon

	sKey := common.SECRET

	sWhere := ` WHERE pgp_sym_decrypt(u.name, ?) = ? OR  pgp_sym_decrypt(u.email, ?) = ?`
	sqlQuery := `
		SELECT
		id
		FROM users u
		` + sWhere + ` `

	var returnRegist models.Users
	result := db.Raw(sqlQuery, sKey, dataUser.Name, sKey, dataUser.Email).First(&returnRegist)
	if result.Error != gorm.ErrRecordNotFound && result.Error != nil {
		// ResultData(nil, "user tidak ditemukan")
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-02",
			Message:    "email atau username sudah dipakai!",
			Data:       make(map[string]string, 1),
		})
	}

	emailByte, _ := encryptData(db, dataUser.Email, sKey)
	nameByte, _ := encryptData(db, dataUser.Name, sKey)
	password, _ := hashPassword(dataUser.Password)

	dataInsert := &models.User{
		ID:         uuid.New(),
		Email:      emailByte,
		Name:       nameByte,
		IsVIP:      false,
		Password:   password,
		DailyCount: 2,
		LastReset:  time.Now(),
	}

	fmt.Println(dataInsert)

	if err := db.Create(&dataInsert).Error; err != nil {
		common.Error.Println("cannot update data , ", err)
		// return err
		return c.Status(fiber.StatusOK).JSON(models.ResultJSON{
			StatusCode: "EYZ-02",
			Message:    "failed",
		})
	}

	return c.Status(fiber.StatusOK).JSON(models.ResultJSON{
		StatusCode: "EYZ-01",
		Message:    "success",
	})
}

// Change Password
// @Summary Change Password
// @Description Change Password
// @Tags User
// @Accept json
// @Produce json
// @Param data body interface{} true "Object data"
// @Success 200 {object} interface{}
// @Router /api/user/changePassword [post]
// @Security ApiKeyAuth
func ChangePassword(c *fiber.Ctx) error {
	dataUser := new(models.ChangePassword)
	if err := c.BodyParser(&dataUser); err != nil {
		return c.JSON(fiber.Map{
			"Statuc Code ": c.Response().Header.StatusCode(),
			"Message":      err,
			"Data":         nil,
		})
	}

	db := database.DBCon

	// get user_id from token
	Key := c.Request().Header.Peek("Bearer")
	tokenString := string(Key[:])
	authParts := strings.Split(tokenString, " ")
	userId := common.GetUser(authParts[1])

	sqlQuery := `
		SELECT 
		u.id, u.password
		FROM users u
		WHERE id = ?
	`

	var user models.Users
	result := db.Raw(sqlQuery, userId).Find(&user)
	if result.Error == gorm.ErrRecordNotFound {
		// ResultData(nil, "user tidak ditemukan")
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-02",
			Message:    "failed to get user data",
			Data:       make(map[string]string, 1),
		})
	}

	if !checkPassword(user.Password, dataUser.OldPassword) {
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-02",
			Message:    "wrong password",
			Data:       make(map[string]string, 1),
		})
	}

	password, _ := hashPassword(dataUser.Password)

	dataUpdate := &models.User{
		Password: password,
	}

	if err := db.Where("id = ?", userId).Updates(&dataUpdate).Error; err != nil {
		common.Error.Println("cannot update data , ", err)
		// return err
		return c.Status(fiber.StatusOK).JSON(models.ResultJSON{
			StatusCode: "EYZ-02",
			Message:    "failed",
		})
	}

	return c.Status(fiber.StatusOK).JSON(models.ResultJSON{
		StatusCode: "EYZ-01",
		Message:    "success",
	})
}

// Change Name
// @Summary Change Name
// @Description Change Name
// @Tags User
// @Accept json
// @Produce json
// @Param data body interface{} true "Object data"
// @Success 200 {object} interface{}
// @Router /api/user/changeName [post]
// @Security ApiKeyAuth
func ChangeName(c *fiber.Ctx) error {
	dataUser := new(models.ChangeName)
	if err := c.BodyParser(&dataUser); err != nil {
		return c.JSON(fiber.Map{
			"Statuc Code ": c.Response().Header.StatusCode(),
			"Message":      err,
			"Data":         nil,
		})
	}

	db := database.DBCon

	// get user_id from token
	Key := c.Request().Header.Peek("Bearer")
	tokenString := string(Key[:])
	authParts := strings.Split(tokenString, " ")
	userId := common.GetUser(authParts[1])

	dataUpdate := &models.User{
		Password: dataUser.Name,
	}

	if err := db.Where("id = ?", userId).Updates(&dataUpdate).Error; err != nil {
		common.Error.Println("cannot update data , ", err)
		// return err
		return c.Status(fiber.StatusOK).JSON(models.ResultJSON{
			StatusCode: "EYZ-02",
			Message:    "failed",
		})
	}

	return c.Status(fiber.StatusOK).JSON(models.ResultJSON{
		StatusCode: "EYZ-01",
		Message:    "success",
	})
}
