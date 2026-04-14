package models

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type PaymentStatus struct {
	gorm.Model
	ID   uuid.UUID `gorm:"primaryKey;type:uuid; default:uuid_generate_v4();"`
	Name string    `gorm:"type:varchar(10)"`
}
