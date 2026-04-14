package common

import (
	"backend/config"
	"context"
	"fmt"
	"io"
	"log"

	"github.com/golang-jwt/jwt"
)

var CurrentVersion = config.Config("CURRENT_VERSION")
var Port = config.Config("PORT")

// JWT Token
var JwtSecret = config.Config("JWTSECRET")
var JwtMaxAge = config.Config("JWTMAXAGE")
var JwtExpiredIn = config.Config("JWTEXPIREDIN")

var SECRET = config.Config("SECRET")

var Ctx = context.Background()

var (
	Trace   *log.Logger
	Info    *log.Logger
	Warning *log.Logger
	Error   *log.Logger
)

func Init(
	traceHandle io.Writer,
	infoHandle io.Writer,
	warningHandle io.Writer,
	errorHandle io.Writer) {

	Trace = log.New(traceHandle,
		"TRACE: ",
		log.Ldate|log.Ltime|log.Lshortfile)

	Info = log.New(infoHandle,
		"INFO: ",
		log.Ldate|log.Ltime|log.Lshortfile)

	Warning = log.New(warningHandle,
		"WARNING: ",
		log.Ldate|log.Ltime|log.Lshortfile)

	Error = log.New(errorHandle,
		"ERROR: ",
		log.Ldate|log.Ltime|log.Lshortfile)
}

func GetUser(token string) string {
	tokenByte, _ := jwt.Parse(token, func(jwtToken *jwt.Token) (interface{}, error) {
		if _, ok := jwtToken.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", jwtToken.Header["alg"])
		}

		return []byte(JwtSecret), nil
	})

	claims, _ := tokenByte.Claims.(jwt.MapClaims)
	dUserId := fmt.Sprintf("%v", claims["user_id"])
	return dUserId
}
