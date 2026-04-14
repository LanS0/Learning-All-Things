package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Subscription struct {
	gorm.Model
	ID            uuid.UUID `gorm:"primaryKey;type:uuid; default:uuid_generate_v4();"`
	UserID        uuid.UUID `gorm:"type:uuid"`
	StartDate     time.Time `gorm:"type:timestamp without time zone"`
	EndDate       time.Time `gorm:"type:timestamp without time zone"`
	PaymentStatus uuid.UUID `gorm:"type:uuid"`
}
