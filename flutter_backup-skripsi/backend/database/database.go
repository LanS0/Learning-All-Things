package database

import (
	"backend/app/controllers/common"
	"backend/config"
	"fmt"
	"log"
	"strconv"
	"time"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DBCon *gorm.DB

func ConnectDB() {
	host := config.Config("DB_NAME")

	var err error
	p := config.Config("DB_PORT")
	port, err := strconv.ParseUint(p, 10, 32)

	if err != nil {
		log.Println("there is a problem when read port DB!")
	}

	// postgres://avnadmin:@pg-1fa85973-michael-cf5a.l.aivencloud.com:27648/defaultdb?sslmode=require
	dsn1 := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=require", config.Config("DB_HOST"), port, config.Config("DB_USER"), config.Config("DB_PASSWORD"), host)
	// dsn1 := fmt.Sprintf("postgres://%s:%s@%s:%d/deafultdb?sslmode=require", config.Config("DB_USER"), config.Config("DB_PASSWORD"), )
	DBCon, err = gorm.Open(postgres.Open(dsn1))

	if err != nil {
		common.Error.Println("failed to connect database, error : " + err.Error())
	} else {
		common.Info.Println("Connection Opened to Database ")
	}

	sqlDBCon, err := DBCon.DB()
	if err != nil {
		common.Error.Println("failed to connect database")
		return
	} else {
		err := sqlDBCon.Ping()
		if err != nil {
			common.Error.Println("failed to ping database")
			return
		}

		sqlDBCon.SetMaxIdleConns(5)
		sqlDBCon.SetConnMaxIdleTime(30 * time.Second)
	}

	DBCon.AutoMigrate(
	// &models.Genre{},
	// &models.History{},
	// &models.PaymentStatus{},
	// &models.Subscription{},
	// &models.User{},
	// &models.Video{},
	// &models.Series{},
	// &models.TvShow{},
	)
}
