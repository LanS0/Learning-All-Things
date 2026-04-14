package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Video struct {
	gorm.Model
	ID          uuid.UUID `gorm:"primaryKey;type:uuid; default:uuid_generate_v4();"`
	Title       string    `gorm:"type:varchar(100)"`
	Description string    `gorm:"type:varchar(255)"`
	Genre       string    `gorm:"type:varchar(255)"`
	Url         string    `gorm:"type:varchar(255)"`
	Thumbnail   string    `gorm:"type:varchar(255)"`
	Year        int       `gorm:"type:integer"`
	Duration    int       `gorm:"type:integer"`
	IsVIP       bool      `gorm:"type:boolean"`
	UploadAt    time.Time `gorm:"type:timestamp without time zone"`
	View        int       `gorm:"type:integer"`
	Viewed      int       `gorm:"type:integer"`
	ComingSoon  bool      `gorm:"type:boolean"`
}

type Videos struct {
	ID          uuid.UUID `json:"id"`
	Title       string    `json:"title"`
	Description string    `json:"description"`
	Genre       string    `json:"genre"`
	GenreString string    `json:"genre_string"`
	Url         string    `json:"url"`
	Thumbnail   string    `json:"thumbnail"`
	Year        int       `json:"year"`
	Duration    int       `json:"duration"`
	IsVIP       bool      `json:"is_v_i_p"`
	UploadAt    time.Time `json:"upload_at"`
	View        int       `json:"view"`
	Viewed      int       `json:"viewed"`
	Total       int       `json:"total"`
}

type Search struct {
	ID          uuid.UUID `json:"id"`
	IsSeries    bool      `json:"is_series"`
	IsVideo     bool      `json:"is_video"`
	Title       string    `json:"title"`
	Description string    `json:"description"`
	Genre       string    `json:"genre"`
	GenreString string    `json:"genre_string"`
	Url         string    `json:"url"`
	Thumbnail   string    `json:"thumbnail"`
	Year        int       `json:"year"`
	Duration    int       `json:"duration"`
	IsVIP       bool      `json:"is_v_i_p"`
	UploadAt    time.Time `json:"upload_at"`
	View        int       `json:"view"`
	Viewed      int       `json:"viewed"`
	Total       int       `json:"total"`
}

type ReturnVideo struct {
	Recent        []Videos `json:"recent"`
	Popular       []Videos `json:"popular"`
	ComingSoon    []Videos `json:"coming_soon"`
	Trending      []Videos `json:"trending"`
	Recomendation []Videos `json:"recomendation"`
}

type Series struct {
	gorm.Model
	ID          uuid.UUID `gorm:"primaryKey;type:uuid; default:uuid_generate_v4();"`
	SeriesID    uuid.UUID `gorm:"type:uuid;"`
	Title       string    `gorm:"type:varchar(100)"`
	Description string    `gorm:"type:varchar(255)"`
	Genre       string    `gorm:"type:varchar(255)"`
	Url         string    `gorm:"type:varchar(255)"`
	Thumbnail   string    `gorm:"type:varchar(255)"`
	Year        int       `gorm:"type:integer"`
	Duration    int       `gorm:"type:integer"`
	IsVIP       bool      `gorm:"type:boolean"`
	UploadAt    time.Time `gorm:"type:timestamp without time zone"`
	View        int       `gorm:"type:integer"`
	Viewed      int       `gorm:"type:integer"`
	ComingSoon  bool      `gorm:"type:boolean"`
}

type Serieses struct {
	ID          uuid.UUID `json:"id"`
	SeriesID    uuid.UUID `json:"series_id"`
	Title       string    `json:"title"`
	Description string    `json:"description"`
	Genre       string    `json:"genre"`
	GenreString string    `json:"genre_string"`
	Url         string    `json:"url"`
	Thumbnail   string    `json:"thumbnail"`
	Year        int       `json:"year"`
	Duration    int       `json:"duration"`
	IsVIP       bool      `json:"is_v_i_p"`
	UploadAt    time.Time `json:"upload_at"`
	View        int       `json:"view"`
	Viewed      int       `json:"viewed"`
	Total       int       `json:"total"`
}

type SeriesByID struct {
	ID          uuid.UUID     `json:"id"`
	SeriesID    uuid.UUID     `json:"series_id"`
	Title       string        `json:"title"`
	Description string        `json:"description"`
	Genre       string        `json:"genre"`
	GenreString string        `json:"genre_string"`
	Url         string        `json:"url"`
	Thumbnail   string        `json:"thumbnail"`
	Year        int           `json:"year"`
	Duration    int           `json:"duration"`
	IsVIP       bool          `json:"is_v_i_p"`
	UploadAt    time.Time     `json:"upload_at"`
	View        int           `json:"view"`
	Viewed      int           `json:"viewed"`
	ListSeries  []interface{} `json:"list_series"`
}

type TvShow struct {
	gorm.Model
	ID          uuid.UUID `gorm:"primaryKey;type:uuid; default:uuid_generate_v4();"`
	ShowID      uuid.UUID `gorm:"type:uuid;"`
	Title       string    `gorm:"type:varchar(100)"`
	Description string    `gorm:"type:varchar(255)"`
	Genre       string    `gorm:"type:varchar(255)"`
	Url         string    `gorm:"type:varchar(255)"`
	Thumbnail   string    `gorm:"type:varchar(255)"`
	Year        int       `gorm:"type:integer"`
	Duration    int       `gorm:"type:integer"`
	IsVIP       bool      `gorm:"type:boolean"`
	UploadAt    time.Time `gorm:"type:timestamp without time zone"`
	View        int       `gorm:"type:integer"`
	Viewed      int       `gorm:"type:integer"`
	ComingSoon  bool      `gorm:"type:boolean"`
}

type TvShows struct {
	ID          uuid.UUID `json:"id"`
	ShowID      uuid.UUID `json:"show_id"`
	Title       string    `json:"title"`
	Description string    `json:"description"`
	Genre       string    `json:"genre"`
	Url         string    `json:"url"`
	Thumbnail   string    `json:"thumbnail"`
	Year        int       `json:"year"`
	Duration    int       `json:"duration"`
	IsVIP       bool      `json:"is_v_i_p"`
	UploadAt    time.Time `json:"upload_at"`
	View        int       `json:"view"`
	Viewed      int       `json:"viewed"`
	Total       int       `json:"total"`
}

type Genre struct {
	gorm.Model
	ID     uuid.UUID `gorm:"primaryKey;type:uuid; default:uuid_generate_v4();"`
	NameId string    `gorm:"type:varchar(25)"`
	NameEn string    `gorm:"type:varchar(25)"`
}

type History struct {
	gorm.Model
	ID        uuid.UUID `gorm:"primaryKey;type:uuid; default:uuid_generate_v4();"`
	UserID    uuid.UUID `gorm:"type:uuid"`
	MovieID   uuid.UUID `gorm:"type:uuid"`
	SeriesID  uuid.UUID `gorm:"type:uuid"`
	WatchedAt time.Time `gorm:"type:timestamp without time zone"`
	Progress  int       `gorm:"type:integer"`
}
