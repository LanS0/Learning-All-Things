package video

import (
	"backend/app/controllers/common"
	"backend/app/models"
	"backend/database"
	"fmt"
	"strconv"
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// GET Video
// @Summary GET Video
// @Description GET Video
// @Tags Video
// @Accept json
// @Produce json
// @Param search query string false "search"
// @Param limit query string true "limit"
// @Param page query string true "page"
// @Param condition query string false "condition"
// @Success 200 {object} interface{}
// @Router /api/video [get]
// @Security ApiKeyAuth
func VideoHome(c *fiber.Ctx) error {
	// search := c.Query("search")
	limit, _ := strconv.Atoi(c.Query("limit"))
	page, _ := strconv.Atoi(c.Query("page"))
	// condition, _ := strconv.Atoi(c.Query("condition"))

	// get user_id from token
	Key := c.Request().Header.Peek("Bearer")
	tokenString := string(Key[:])
	authParts := strings.Split(tokenString, " ")
	userId := common.GetUser(authParts[1])

	db := database.DBCon

	sWhere := " WHERE v.deleted_at IS NULL "
	// if search != "" {
	// 	if condition == 1 {
	// 		sWhere += " AND v.title ILIKE '%" + search + "%' "
	// 	} else if condition == 2 {
	// 		sWhere += " AND v.description ILIKE '%" + search + "%' "
	// 	} else if condition == 3 {
	// 		sWhere += " AND v.remark_update ILIKE '%" + search + "%' "
	// 	} else {
	// 		sWhere += ` AND CONCAT(v.title, v.description, v.remark_update) ILIKE '%` + search + "%' "
	// 	}
	// }

	sqlQueryPopular := `
		SELECT COUNT(*) OVER() total, 
		v.*
		FROM videos v
		` + sWhere + ` AND v.coming_soon = FALSE
		ORDER BY v.updated_at DESC, v.view DESC
		OFFSET((? - 1) * ?)
		LIMIT(?)
	`

	var popular []models.Videos
	result := db.Raw(sqlQueryPopular, page, limit, limit).Find(&popular)
	if result.Error == gorm.ErrRecordNotFound {
		// ResultData(nil, "user tidak ditemukan")
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-02",
			Message:    "not found video",
			Data:       make(map[string]string, 1),
		})
	}

	sqlQueryComingSoon := `
		SELECT COUNT(*) OVER() total, 
		v.*
		FROM videos v
		` + sWhere + ` AND v.coming_soon = TRUE
		ORDER BY v.updated_at DESC
		OFFSET((? - 1) * ?)
		LIMIT(?)
	`

	var comingSoon []models.Videos
	result = db.Raw(sqlQueryComingSoon, page, limit, limit).Find(&comingSoon)
	if result.Error == gorm.ErrRecordNotFound {
		// ResultData(nil, "user tidak ditemukan")
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-02",
			Message:    "not found video",
			Data:       make(map[string]string, 1),
		})
	}

	sqlQueryRecomendation := `
		SELECT COUNT(*) OVER() total, 
		v.*
		FROM videos v
		` + sWhere + `
		ORDER BY v.updated_at DESC, RANDOM()
		OFFSET((? - 1) * ?)
		LIMIT(?)
	`

	var recomendation []models.Videos
	result = db.Raw(sqlQueryRecomendation, page, limit, limit).Find(&recomendation)
	if result.Error == gorm.ErrRecordNotFound {
		// ResultData(nil, "user tidak ditemukan")
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-02",
			Message:    "not found video",
			Data:       make(map[string]string, 1),
		})
	}

	// TRENDING
	sqlQueryTrending := `
		SELECT COUNT(*) OVER() total, 
		v.*
		FROM videos v
		` + sWhere + `
		ORDER BY v.updated_at DESC, v.viewed DESC
		OFFSET((? - 1) * ?)
		LIMIT(?)
	`

	var trending []models.Videos
	result = db.Raw(sqlQueryTrending, page, limit, limit).Find(&trending)
	if result.Error == gorm.ErrRecordNotFound {
		// ResultData(nil, "user tidak ditemukan")
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-02",
			Message:    "not found video",
			Data:       make(map[string]string, 1),
		})
	}

	var recentID string
	sqlQueryGetRecent := `
		SELECT
		u.recent
		FROM users u
		WHERE id = ?
	`

	result = db.Raw(sqlQueryGetRecent, userId).First(&recentID)
	if result.Error == gorm.ErrRecordNotFound {
		// ResultData(nil, "user tidak ditemukan")
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-02",
			Message:    "not found video",
			Data:       make(map[string]string, 1),
		})
	}

	var recent []models.Videos
	if recentID != "" {
		sqlQueryRecent := `
			SELECT COUNT(*) OVER() total, 
			v.*
			FROM videos v
			WHERE v.id = ?
			ORDER BY v.updated_at DESC
			OFFSET((? - 1) * ?)
			LIMIT(?)
		`

		result = db.Raw(sqlQueryRecent, recentID, page, limit, limit).Find(&recent)
		if result.Error == gorm.ErrRecordNotFound {
			// ResultData(nil, "user tidak ditemukan")
			return c.JSON(models.ResultJSON{
				StatusCode: "EYZ-02",
				Message:    "not found video",
				Data:       make(map[string]string, 1),
			})
		}
	}

	var video models.ReturnVideo

	video.ComingSoon = comingSoon
	video.Popular = popular
	video.Trending = trending
	video.Recomendation = recomendation
	video.Recent = recent

	return c.Status(fiber.StatusOK).JSON(models.ResultJSON{
		StatusCode: "EYZ-01",
		Message:    "success",
		Data:       video,
	})
}

// GET Video
// @Summary GET Video
// @Description GET Video
// @Tags Video
// @Accept json
// @Produce json
// @Param id query string true "id"
// @Success 200 {object} interface{}
// @Router /api/video/{id} [get]
// @Security ApiKeyAuth
func VideosByID(c *fiber.Ctx) error {
	id := c.Query("id")

	db := database.DBCon

	sWhere := " WHERE v.deleted_at IS NULL AND v.id = ? "

	sqlQuery := `
		SELECT 
		v.*
		FROM videos v
		` + sWhere + `
	`

	var video models.Videos
	result := db.Raw(sqlQuery, id).Find(&video)
	if result.Error == gorm.ErrRecordNotFound {
		// ResultData(nil, "user tidak ditemukan")
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-03",
			Message:    "not found video",
			Data:       make(map[string]string, 1),
		})
	} else if result.Error != nil {
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-03",
			Message:    "error",
			Data:       make(map[string]string, 1),
		})
	}

	var dataGenre []models.Genre
	if err := db.Table("genres").
		Select("*").
		Find(&dataGenre).Error; err != nil {
		common.Error.Print(fmt.Errorf("ada error saat set ke redis : %s", err))
		return c.Status(fiber.StatusOK).JSON(models.ResultJSON{
			StatusCode: "EYZ-03",
			Message:    "not found video",
			Data:       make(map[string]string, 1),
		})
	}

	seenGenre := make(map[uuid.UUID]bool)
	seenGenreString := make(map[uuid.UUID]string)
	for _, val := range dataGenre {
		if !seenGenre[val.ID] {
			seenGenreString[val.ID] = val.NameId
			seenGenre[val.ID] = true
		}
	}

	data := strings.Split(video.Genre, ",")
	var genre string
	for j, vals := range data {
		id, _ := uuid.Parse(vals)
		if len(data) == 1 {
			genre += seenGenreString[id]
		} else if len(data) > 1 {
			if j == len(data)-1 {
				genre += seenGenreString[id]
			} else {
				genre += seenGenreString[id] + ", "
			}
		}
	}

	video.GenreString = genre

	return c.Status(fiber.StatusOK).JSON(models.ResultJSON{
		StatusCode: "EYZ-01",
		Message:    "success",
		Data:       video,
	})
}

// GET Video
// @Summary GET Video
// @Description GET Video
// @Tags Video
// @Accept json
// @Produce json
// @Param search query string false "search"
// @Param limit query string true "limit"
// @Param page query string true "page"
// @Param condition query string true "condition"
// @Success 200 {object} interface{}
// @Router /api/video/search [get]
// @Security ApiKeyAuth
func VideoSearch(c *fiber.Ctx) error {
	search := c.Query("search")
	limit, _ := strconv.Atoi(c.Query("limit"))
	page, _ := strconv.Atoi(c.Query("page"))
	condition, _ := strconv.Atoi(c.Query("condition"))

	// // get user_id from token
	// Key := c.Request().Header.Peek("Bearer")
	// tokenString := string(Key[:])
	// authParts := strings.Split(tokenString, " ")
	// userId := common.GetUser(authParts[1])

	db := database.DBCon

	sWhereMovies := " WHERE v.deleted_at IS NULL "
	if search != "" {
		if condition == 1 {
			sWhereMovies += " AND v.title ILIKE '%" + search + "%' "
		} else {
			sWhereMovies += ` AND CONCAT(v.title) ILIKE '%` + search + "%' "
		}
	}

	sWhereSeries := " WHERE s.deleted_at IS NULL AND s.series_id IS NULL "
	if search != "" {
		if condition == 2 {
			sWhereSeries += " AND s.title ILIKE '%" + search + "%' "
		} else {
			sWhereSeries += " AND CONCAT(s.title) ILIKE '%" + search + "%' "
		}
	}

	sqlSearch := `
	(
		SELECT v.id, v.title, v.thumbnail, TRUE as is_video, FALSE as is_series
		FROM videos v
		` + sWhereMovies + `
		ORDER BY v.updated_at DESC
		OFFSET((? - 1) * ?)
		LIMIT(?)
	)
	UNION ALL
	(
		SELECT s.id, s.title, s.thumbnail, TRUE as is_video, FALSE as is_series
		FROM series s
		` + sWhereSeries + `
		ORDER BY s.updated_at DESC
		OFFSET((? - 1) * ?)
		LIMIT(?)
	);
	`

	var searchResult []models.Search
	result := db.Raw(sqlSearch, page, limit, limit, page, limit, limit).Find(&searchResult)
	if result.Error == gorm.ErrRecordNotFound {
		// ResultData(nil, "user tidak ditemukan")
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-02",
			Message:    "not found video",
			Data:       make(map[string]string, 1),
		})
	}

	return c.Status(fiber.StatusOK).JSON(models.ResultJSON{
		StatusCode: "EYZ-01",
		Message:    "success",
		Data:       searchResult,
	})

}

// GET Tv Shows
// @Summary GET Tv Shows
// @Description GET Tv Shows
// @Tags Tv Shows
// @Accept json
// @Produce json
// @Param search query string false "search"
// @Param limit query string true "limit"
// @Param page query string true "page"
// @Param condition query string false "condition"
// @Success 200 {object} interface{}
// @Router /api/tvShows [get]
// @Security ApiKeyAuth
func GetTV(c *fiber.Ctx) error {
	// search := c.Query("search")
	limit, _ := strconv.Atoi(c.Query("limit"))
	page, _ := strconv.Atoi(c.Query("page"))
	// condition, _ := strconv.Atoi(c.Query("condition"))

	// // get user_id from token
	// Key := c.Request().Header.Peek("Bearer")
	// tokenString := string(Key[:])
	// authParts := strings.Split(tokenString, " ")
	// userId := common.GetUser(authParts[1])

	db := database.DBCon

	sWhere := " WHERE tv.deleted_at IS NULL AND tv.show_id IS NULL"
	sqlQueryTv := `
		SELECT COUNT(*) OVER() total, 
		tv.*
		FROM tv_shows tv
		` + sWhere + ` AND tv.coming_soon = FALSE
		ORDER BY tv.updated_at DESC, tv.view DESC
		OFFSET((? - 1) * ?)
		LIMIT(?)
	`

	var tvShow []models.TvShows
	result := db.Raw(sqlQueryTv, page, limit, limit).Find(&tvShow)
	if result.Error == gorm.ErrRecordNotFound {
		// ResultData(nil, "user tidak ditemukan")
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-02",
			Message:    "not found video",
			Data:       make(map[string]string, 1),
		})
	}

	return c.Status(fiber.StatusOK).JSON(models.ResultJSON{
		StatusCode: "EYZ-01",
		Message:    "success",
		Data:       tvShow,
	})
}

// GET Tv Shows
// @Summary GET Tv Shows
// @Description GET Tv Shows
// @Tags Tv Shows
// @Accept json
// @Produce json
// @Param id query string true "id"
// @Success 200 {object} interface{}
// @Router /api/tvShows/{id} [get]
// @Security ApiKeyAuth
func GetTVByID(c *fiber.Ctx) error {
	id := c.Query("id")

	db := database.DBCon

	sWhere := " WHERE tv.deleted_at IS NULL AND tv.id = ? "

	sqlQuery := `
		SELECT 
		tv.*
		FROM tv_shows tv
		` + sWhere + `
	`

	var tvShows models.TvShows
	result := db.Raw(sqlQuery, id).Find(&tvShows)
	if result.Error == gorm.ErrRecordNotFound {
		// ResultData(nil, "user tidak ditemukan")
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-03",
			Message:    "not found tvShows",
			Data:       make(map[string]string, 1),
		})
	} else if result.Error != nil {
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-03",
			Message:    "error",
			Data:       make(map[string]string, 1),
		})
	}

	return c.Status(fiber.StatusOK).JSON(models.ResultJSON{
		StatusCode: "EYZ-01",
		Message:    "success",
		Data:       tvShows,
	})
}

// GET Series
// @Summary GET Series
// @Description GET Series
// @Tags Series
// @Accept json
// @Produce json
// @Param search query string false "search"
// @Param limit query string true "limit"
// @Param page query string true "page"
// @Param condition query string false "condition"
// @Success 200 {object} interface{}
// @Router /api/series [get]
// @Security ApiKeyAuth
func GetSeries(c *fiber.Ctx) error {
	// search := c.Query("search")
	limit, _ := strconv.Atoi(c.Query("limit"))
	page, _ := strconv.Atoi(c.Query("page"))
	// condition, _ := strconv.Atoi(c.Query("condition"))

	// // get user_id from token
	// Key := c.Request().Header.Peek("Bearer")
	// tokenString := string(Key[:])
	// authParts := strings.Split(tokenString, " ")
	// userId := common.GetUser(authParts[1])

	db := database.DBCon

	sWhere := " WHERE s.deleted_at IS NULL AND s.series_id IS NULL"
	sqlQueryTv := `
		SELECT COUNT(*) OVER() total, 
		s.*
		FROM series s
		` + sWhere + ` AND s.coming_soon = FALSE
		ORDER BY s.updated_at DESC, s.view DESC
		OFFSET((? - 1) * ?)
		LIMIT(?)
	`

	var series []models.Serieses
	result := db.Raw(sqlQueryTv, page, limit, limit).Find(&series)
	if result.Error == gorm.ErrRecordNotFound {
		// ResultData(nil, "user tidak ditemukan")
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-02",
			Message:    "not found video",
			Data:       make(map[string]string, 1),
		})
	}

	return c.Status(fiber.StatusOK).JSON(models.ResultJSON{
		StatusCode: "EYZ-01",
		Message:    "success",
		Data:       series,
	})
}

// GET Tv Shows
// @Summary GET Tv Shows
// @Description GET Tv Shows
// @Tags Tv Shows
// @Accept json
// @Produce json
// @Param id query string true "id"
// @Success 200 {object} interface{}
// @Router /api/series/{id} [get]
// @Security ApiKeyAuth
func GetSeriesByID(c *fiber.Ctx) error {
	id := c.Query("id")

	db := database.DBCon

	sWhere := " WHERE s.deleted_at IS NULL AND s.id = ? "

	sqlQuery := `
		SELECT 
		s.*
		FROM series s
		` + sWhere + `
	`

	var series models.SeriesByID
	result := db.Raw(sqlQuery, id).Find(&series)
	if result.Error == gorm.ErrRecordNotFound {
		// ResultData(nil, "user tidak ditemukan")
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-03",
			Message:    "not found series",
			Data:       make(map[string]string, 1),
		})
	} else if result.Error != nil {
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-03",
			Message:    "error",
			Data:       make(map[string]string, 1),
		})
	}

	sWhere = " WHERE s.deleted_at IS NULL AND (s.id = ? OR s.series_id = ?) "

	sqlQuery = `
		SELECT 
		s.*
		FROM series s
		` + sWhere + `
	`

	if series.SeriesID.String() == uuid.Nil.String() {
		var seriesList []models.Serieses
		result = db.Raw(sqlQuery, id, id).Find(&seriesList)
		if result.Error == gorm.ErrRecordNotFound {
			// ResultData(nil, "user tidak ditemukan")
			return c.JSON(models.ResultJSON{
				StatusCode: "EYZ-03",
				Message:    "not found series",
				Data:       make(map[string]string, 1),
			})
		} else if result.Error != nil {
			return c.JSON(models.ResultJSON{
				StatusCode: "EYZ-03",
				Message:    "error",
				Data:       make(map[string]string, 1),
			})
		}

		for _, val := range seriesList {
			series.ListSeries = append(series.ListSeries, val)
		}
	} else {
		var seriesList []models.Serieses
		result = db.Raw(sqlQuery, id, series.SeriesID).Find(&seriesList)
		if result.Error == gorm.ErrRecordNotFound {
			// ResultData(nil, "user tidak ditemukan")
			return c.JSON(models.ResultJSON{
				StatusCode: "EYZ-03",
				Message:    "not found series",
				Data:       make(map[string]string, 1),
			})
		} else if result.Error != nil {
			return c.JSON(models.ResultJSON{
				StatusCode: "EYZ-03",
				Message:    "error",
				Data:       make(map[string]string, 1),
			})
		}

		for _, val := range seriesList {
			series.ListSeries = append(series.ListSeries, val)
		}
	}

	return c.Status(fiber.StatusOK).JSON(models.ResultJSON{
		StatusCode: "EYZ-01",
		Message:    "success",
		Data:       series,
	})
}

// GET Favorite
// @Summary GET Favorite
// @Description GET Favorite
// @Tags VideoStatus
// @Accept json
// @Produce json
// @Param id query string true "id"
// @Param status query int true "status"
// @Success 200 {object} interface{}
// @Router /api/favorite [get]
// @Security ApiKeyAuth
func Favorite(c *fiber.Ctx) error {
	id := c.Query("id")
	status, _ := strconv.Atoi(c.Query("status"))

	db := database.DBCon

	// get user_id from token
	Key := c.Request().Header.Peek("Bearer")
	tokenString := string(Key[:])
	authParts := strings.Split(tokenString, " ")
	userId := common.GetUser(authParts[1])

	sWhere := " WHERE u.id = ? "

	sqlQuery := `
		SELECT 
		u.favorite
		FROM users u
		` + sWhere + `
	`

	var favorite string
	result := db.Raw(sqlQuery, userId).Scan(&favorite)
	if result.Error == gorm.ErrRecordNotFound {
		// ResultData(nil, "user tidak ditemukan")
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-03",
			Message:    "not found tvShows",
			Data:       make(map[string]string, 1),
		})
	} else if result.Error != nil {
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-03",
			Message:    "error",
			Data:       make(map[string]string, 1),
		})
	}

	var listBaruFavorite string

	dataFavorite := strings.Split(favorite, ",")

	if status == 1 {
		if len(dataFavorite) == 0 {
			listBaruFavorite = id
		} else {
			listBaruFavorite = strings.Join(dataFavorite, ",") + "," + id
		}

		dataUpdate := &models.User{
			Favorite: listBaruFavorite,
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
	} else if status == 2 {
		var newList []string
		for _, val := range dataFavorite {
			if id != val {
				newList = append(newList, val)
			}
		}

		dataUpdate := &models.User{
			Favorite: strings.Join(newList, ","),
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

	return c.Status(fiber.StatusOK).JSON(models.ResultJSON{
		StatusCode: "EYZ-02",
		Message:    "status not found",
	})
}

// GET Like
// @Summary GET Like
// @Description GET Like
// @Tags VideoStatus
// @Accept json
// @Produce json
// @Param id query string true "id"
// @Param status query int true "status"
// @Success 200 {object} interface{}
// @Router /api/like [get]
// @Security ApiKeyAuth
func Like(c *fiber.Ctx) error {
	id := c.Query("id")
	status, _ := strconv.Atoi(c.Query("status"))

	db := database.DBCon

	// get user_id from token
	Key := c.Request().Header.Peek("Bearer")
	tokenString := string(Key[:])
	authParts := strings.Split(tokenString, " ")
	userId := common.GetUser(authParts[1])

	sWhere := " WHERE u.id = ? "

	sqlQuery := `
		SELECT 
		u.like
		FROM users u
		` + sWhere + `
	`

	var like string
	result := db.Raw(sqlQuery, userId).Scan(&like)
	if result.Error == gorm.ErrRecordNotFound {
		// ResultData(nil, "user tidak ditemukan")
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-03",
			Message:    "not found tvShows",
			Data:       make(map[string]string, 1),
		})
	} else if result.Error != nil {
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-03",
			Message:    "error",
			Data:       make(map[string]string, 1),
		})
	}

	var listBaruLike string

	dataLike := strings.Split(like, ",")

	if status == 1 {
		if len(dataLike) == 0 {
			listBaruLike = id
		} else {
			listBaruLike = strings.Join(dataLike, ",") + "," + id
		}

		dataUpdate := &models.User{
			Like: listBaruLike,
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
	} else if status == 2 {
		var newList []string
		for _, val := range dataLike {
			if id != val {
				newList = append(newList, val)
			}
		}

		dataUpdate := &models.User{
			Like: strings.Join(newList, ","),
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

	return c.Status(fiber.StatusOK).JSON(models.ResultJSON{
		StatusCode: "EYZ-02",
		Message:    "status not found",
	})
}

// GET Recent
// @Summary GET Recent
// @Description GET Recent
// @Tags Tv Shows
// @Accept json
// @Produce json
// @Param id query string true "id"
// @Param status query int true "status"
// @Success 200 {object} interface{}
// @Router /api/recent [get]
// @Security ApiKeyAuth
func Recent(c *fiber.Ctx) error {
	id := c.Query("id")
	status, _ := strconv.Atoi(c.Query("status"))

	db := database.DBCon

	// get user_id from token
	Key := c.Request().Header.Peek("Bearer")
	tokenString := string(Key[:])
	authParts := strings.Split(tokenString, " ")
	userId := common.GetUser(authParts[1])

	sWhere := " WHERE u.id = ? "

	sqlQuery := `
		SELECT 
		u.recent
		FROM users u
		` + sWhere + `
	`

	var recent string
	result := db.Raw(sqlQuery, userId).Scan(&recent)
	if result.Error == gorm.ErrRecordNotFound {
		// ResultData(nil, "user tidak ditemukan")
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-03",
			Message:    "not found tvShows",
			Data:       make(map[string]string, 1),
		})
	} else if result.Error != nil {
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-03",
			Message:    "error",
			Data:       make(map[string]string, 1),
		})
	}

	var listBaruRecent string

	dataRecent := strings.Split(recent, ",")

	if status == 1 {
		if len(dataRecent) == 0 {
			listBaruRecent = id
		} else {
			listBaruRecent = strings.Join(dataRecent, ",") + "," + id
		}

		dataUpdate := &models.User{
			Recent: listBaruRecent,
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
	} else if status == 2 {
		var newList []string
		for _, val := range dataRecent {
			if id != val {
				newList = append(newList, val)
			}
		}

		dataUpdate := &models.User{
			Recent: strings.Join(newList, ","),
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

	return c.Status(fiber.StatusOK).JSON(models.ResultJSON{
		StatusCode: "EYZ-02",
		Message:    "status not found",
	})
}
