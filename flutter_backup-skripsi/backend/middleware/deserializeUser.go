package middleware

import (
	"backend/app/controllers/common"
	"backend/app/models"
	"fmt"
	"strings"

	// "errors"

	"github.com/gofiber/fiber/v2"

	"github.com/golang-jwt/jwt"
)

func DeserializeUser(c *fiber.Ctx) error {
	var tokenString string
	authHeader := c.Get("Bearer")

	if authHeader == "" {
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-05",
			Message:    "Missing Authorization header",
			Data:       make([]string, 0),
		})
	}

	authParts := strings.Split(authHeader, " ")
	if len(authParts) != 2 || authParts[0] != "Bearer" {
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-05",
			Message:    "Invalid or missing Bearer token",
			Data:       make([]string, 0),
		})
	}

	tokenString = authParts[1]

	tokenByte, err := jwt.Parse(tokenString, func(jwtToken *jwt.Token) (interface{}, error) {
		if _, ok := jwtToken.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", jwtToken.Header["alg"])
		}

		return []byte(common.JwtSecret), nil
	})

	if !tokenByte.Valid {
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-05",
			Message:    fmt.Sprintf("invalidate token: %v", err),
			Data:       make([]string, 0),
		})
	}

	_, ok := tokenByte.Claims.(jwt.MapClaims)
	if !ok || !tokenByte.Valid {
		return c.JSON(models.ResultJSON{
			StatusCode: "EYZ-05",
			Message:    "invalid token claim",
			Data:       make([]string, 0),
		})
	}

	return c.Next()
}
