package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// struct {
// 	gorm.Model
//	uuid.UUID `gorm:"primaryKey;type:uuid; default:uuid_generate_v4();"`
// 	string    `gorm:"type:varchar(255)"`
//	time.Time `gorm:"type:timestamp"`
//	int       `gorm:"type:integer"`
//	float64   `gorm:"type:numeric(15,3)"`
//	bool      `gorm:"type:boolean"`
// 	[]byte    `gorm:"type:bytea"`
// }

type User struct {
	gorm.Model
	ID         uuid.UUID `gorm:"primaryKey;type:uuid; default:uuid_generate_v4();"`
	Name       []byte    `gorm:"type:bytea"`
	Email      []byte    `gorm:"type:bytea"`
	IsVIP      bool      `gorm:"type:boolean"`
	Password   string
	Favorite   string    `gorm:"varchar"`
	Like       string    `gorm:"varchar"`
	Recent     string    `gorm:"varchar"`
	DailyCount int       `gorm:"type:integer"`
	LastReset  time.Time `gorm:"type:timestamp without time zone"`
}

type Users struct {
	gorm.Model
	ID       uuid.UUID `gorm:"primaryKey;type:uuid; default:uuid_generate_v4();"`
	Name     string    `gorm:"type:bytea"`
	Email    string    `gorm:"type:bytea"`
	IsVIP    bool      `gorm:"type:boolean"`
	Password string
	Favorite string `gorm:"varchar"`
	Like     string `gorm:"varchar"`
	Recent   string `gorm:"varchar"`
}

type ReturnUser struct {
	ID       uuid.UUID `json:"id"`
	Name     string    `json:"name"`
	Email    string    `json:"email"`
	IsVIP    bool      `json:"is_v_i_p"`
	Favorite string    `json:"favorite"`
	Like     string    `json:"like"`
}

type InsertUser struct {
	Email    string `json:"email"`
	Name     string `json:"name"`
	Password string `json:"password"`
}

type ChangeName struct {
	Name string `json:"name"`
}

type ChangePassword struct {
	OldPassword string `json:"old_password"`
	Password    string `json:"password"`
}
