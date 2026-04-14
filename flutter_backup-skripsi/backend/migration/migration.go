package migration

import (
	"backend/app/controllers/common"
	"backend/app/models"
	"backend/database"
	"fmt"
	"strings"
	"time"

	"github.com/gofiber/fiber/v2/log"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

func encryptData(db *gorm.DB, data string, key string) ([]byte, error) {
	var encryptedData []byte
	err := db.Raw("SELECT pgp_sym_encrypt(?, ?)", data, key).Row().Scan(&encryptedData)
	if err != nil {
		return []byte("hai"), err
	}

	return encryptedData, nil
}

// Seed seeds the database with initial data
func SeedMaster() {
	db := database.DBCon
	sqlDBCon, err := db.DB()
	if err != nil {
		common.Error.Println("failed to connect database")
		return
	} else {
		err := sqlDBCon.Ping()
		if err != nil {
			common.Error.Println("failed to ping database")
			return
		}
	}

	// // GENRE
	// genreData := []models.Genre{
	// 	{ID: uuid.New(), NameId: "Aksi", NameEn: "Action"},
	// 	{ID: uuid.New(), NameId: "Animasi", NameEn: "Animation"},
	// 	{ID: uuid.New(), NameId: "Perang", NameEn: "War"},
	// 	{ID: uuid.New(), NameId: "Horror", NameEn: "Horror"},
	// 	{ID: uuid.New(), NameId: "Drama", NameEn: "Drama"},
	// 	{ID: uuid.New(), NameId: "Romansa", NameEn: "Romance"},
	// 	{ID: uuid.New(), NameId: "Komedi", NameEn: "Comedy"},
	// 	{ID: uuid.New(), NameId: "Musikal", NameEn: "Musical"},
	// 	{ID: uuid.New(), NameId: "Keluarga", NameEn: "Family"},
	// }

	// for _, data := range genreData {
	// 	var existingData models.Genre
	// 	result := db.Where("name_id = ?", data.NameId).First(&existingData)
	// 	if result.Error != nil && result.Error.Error() == gorm.ErrRecordNotFound.Error() {

	// 		if err := db.Create(&data).Error; err != nil {
	// 			log.Fatal("Error inserting data '%s': %v\n", data.NameId, err)
	// 		} else {
	// 			log.Info("data '%s' inserted successfully.\n", data.NameId)
	// 		}
	// 	}
	// }

	// // PAYMENT STATUS
	// paymentStatus := []models.PaymentStatus{
	// 	{ID: uuid.New(), Name: "FAILED"},
	// 	{ID: uuid.New(), Name: "SUCCESS"},
	// 	{ID: uuid.New(), Name: "PENDING"},
	// }

	// for _, data := range paymentStatus {
	// 	var existingData models.PaymentStatus
	// 	result := db.Where("name = ?", data.Name).First(&existingData)
	// 	if result.Error != nil && result.Error.Error() == gorm.ErrRecordNotFound.Error() {

	// 		if err := db.Create(&data).Error; err != nil {
	// 			log.Fatal("Error inserting data '%s': %v\n", data.Name, err)
	// 		} else {
	// 			log.Info("data '%s' inserted successfully.\n", data.Name)
	// 		}
	// 	}
	// }

	var dataGenre []models.Genre
	if err := db.Table("genres").
		Select("*").
		Find(&dataGenre).Error; err != nil {
		common.Error.Print(fmt.Errorf("ada error saat set ke redis : %s", err))
	}

	// var ActionUUID uuid.UUID
	var AnimationUUID uuid.UUID
	// var WarUUID uuid.UUID
	// var HorrorUUID uuid.UUID
	// var DramaUUID uuid.UUID
	// var RomanceUUID uuid.UUID
	// var ComedyUUID uuid.UUID
	// var FamilyUUID uuid.UUID
	// var MusicalUUID uuid.UUID
	for _, val := range dataGenre {
		// if strings.EqualFold(val.NameEn, "action") {
		// 	ActionUUID = val.ID
		// } else
		if strings.EqualFold(val.NameEn, "animation") {
			AnimationUUID = val.ID
		}
		//  else if strings.EqualFold(val.NameEn, "war") {
		// 	// 	WarUUID = val.ID
		// 	// } else if strings.EqualFold(val.NameEn, "horror") {
		// 	// 	HorrorUUID = val.ID
		// } else if strings.EqualFold(val.NameEn, "drama") {
		// 	DramaUUID = val.ID
		// } else if strings.EqualFold(val.NameEn, "romance") {
		// 	RomanceUUID = val.ID
		// } else if strings.EqualFold(val.NameEn, "comedy") {
		// 	ComedyUUID = val.ID
		// } else if strings.EqualFold(val.NameEn, "musical") {
		// 	MusicalUUID = val.ID
		// } else if strings.EqualFold(val.NameEn, "family") {
		// 	FamilyUUID = val.ID
		// }
	}

	// // Video
	// dataVideo := []models.Video{
	// 	// {ID: uuid.New(), Title: "The Gold Rush", Year: 1925, Description: "", IsVIP: true, UploadAt: time.Now(), Url: "https://archive.org/download/GoldRush_1006/GoldRush_1006.mp4", Genre: ComedyUUID.String()},
	// 	// {ID: uuid.New(), Title: "The General", Year: 1926, Description: "", IsVIP: true, UploadAt: time.Now(), Url: "https://archive.org/download/TheGeneral1926/TheGeneral1926.mp4", Genre: ComedyUUID.String() + "," + ActionUUID.String()},
	// 	// {ID: uuid.New(), Title: "A Star Is Born", Year: 1937, Description: "", IsVIP: false, UploadAt: time.Now(), Url: "https://archive.org/download/AStarIsBorn1937/AStarIsBorn1937.mp4", Genre: DramaUUID.String() + "," + RomanceUUID.String()},
	// 	// {ID: uuid.New(), Title: "His Girl Friday", Year: 1940, Description: "", IsVIP: false, UploadAt: time.Now(), Url: "https://archive.org/download/HisGirlFriday_1940/HisGirlFriday.mp4", Genre: ComedyUUID.String()},
	// 	// {ID: uuid.New(), Title: "It’s a Wonderful Life", Year: 1946, Description: "", IsVIP: false, UploadAt: time.Now(), Url: "https://archive.org/download/ItsAWonderfulLife_1946/ItsAWonderfulLife.mp4", Genre: DramaUUID.String()},
	// 	// {ID: uuid.New(), Title: "March of the Wooden Soldiers", Year: 1934, Description: "", IsVIP: false, UploadAt: time.Now(), Url: "https://archive.org/download/MarchOfTheWoodenSoldiers/MarchOfTheWoodenSoldiers.mp4", Genre: MusicalUUID.String() + "," + FamilyUUID.String()},
	// 	// {ID: uuid.New(), Title: "The Cameraman", Year: 1928, Description: "", IsVIP: false, UploadAt: time.Now(), Url: "https://archive.org/download/TheCameraman1928/TheCameraman1928.mp4", Genre: ComedyUUID.String() + "," + RomanceUUID.String()},
	// 	// {ID: uuid.New(), Title: "Steamboat Willie", Year: 1928, Description: "", IsVIP: false, UploadAt: time.Now(), Url: "https://archive.org/download/SteamboatWillie1928/SteamboatWillie1928.mp4", Genre: AnimationUUID.String()},
	// 	// {ID: uuid.New(), Title: "Fred Ott’s Sneeze", Year: 1894, Description: "", IsVIP: false, UploadAt: time.Now(), Url: "https://archive.org/download/FredOttsSneeze/FredOttsSneeze.mp4", Genre: ActionUUID.String()},
	// 	// {ID: uuid.New(), Title: "Popeye Meets Sinbad", Year: 1936, Description: "", IsVIP: false, UploadAt: time.Now(), Url: "https://archive.org/download/PopeyeMeetsSindbad/PopeyeMeetsSindbad.mp4", Genre: AnimationUUID.String()},
	// 	// {ID: uuid.New(), Title: "Frankenstein 1931 colorized (Colin Clive, Boris Karloff)", Year: 1931, Description: `Dr. Frankenstein is obsessed with re-animating the dead. He succeeds in assembling a living being from parts of several exhumed corpses, creating a confused monster.`, IsVIP: false, UploadAt: time.Now(), Url: "https://archive.org/download/frankenstein-1931-colorized/Frankenstein-1931-colorized.mp4", Thumbnail: "https://archive.org/services/img/frankenstein-1931-colorized", Genre: ActionUUID.String(), View: 20812},
	// 	// {ID: uuid.New(), Title: "Popeye: Gopher Spinach", Year: 1954, Description: `Popeye tries to rid his garden of a gopher, in the end the gopher saves Popeye from a bull.`, IsVIP: true, UploadAt: time.Now(), Url: "https://archive.org/download/Popeye_Gopher_Spinach_1954_871/Popeye_Gopher_Spinach_512kb.mp4", Thumbnail: "https://archive.org/services/img/Popeye_Gopher_Spinach_1954_871", Genre: AnimationUUID.String(), View: 261388},
	// }

	// for _, data := range dataVideo {
	// 	var existingData models.Video
	// 	result := db.Where("title = ?", data.Title).First(&existingData)
	// 	if result.Error != nil && result.Error.Error() == gorm.ErrRecordNotFound.Error() {
	// 		if err := db.Create(&data).Error; err != nil {
	// 			log.Fatal("Error inserting data '%s': %v\n", data.Title, err)
	// 		} else {
	// 			log.Info("data '%s' inserted successfully.\n", data.Title)
	// 		}
	// 	}
	// }

	seriesUUID, _ := uuid.Parse("85956d31-78c3-49ed-bb8c-9057dfc2f798")

	// Series
	dataSeries := []models.Series{
		// {ID: uuid.New(), Title: "Frankenstein 1931 colorized (Colin Clive, Boris Karloff)", Year: 1931, Description: `Dr. Frankenstein is obsessed with re-animating the dead. He succeeds in assembling a living being from parts of several exhumed corpses, creating a confused monster.`, IsVIP: false, UploadAt: time.Now(), Url: "https://archive.org/download/frankenstein-1931-colorized/Frankenstein-1931-colorized.mp4", Thumbnail: "https://archive.org/services/img/frankenstein-1931-colorized", Genre: ActionUUID.String(), View: 20812},
		// {ID: uuid.New(), Title: "The Pink Panther", Year: 1964,
		// 	Description: `The Pink Panther animated shorts produced between December 18, 1964 and February 1, 1980 by DePatie-Freleng Enterprises (DFE Films).`, IsVIP: true,
		// 	UploadAt: time.Now(), Url: "https://archive.org/download/ThePinkPanther-cartoons/The%20Pink%20Panther%20in%20-A%20Fly%20in%20the%20Pink.mp4",
		// 	Thumbnail: "https://archive.org/services/img/ThePinkPanther-cartoons", Genre: AnimationUUID.String(), View: 240197},
		{ID: uuid.New(), Title: "The Pink Panther", Year: 1964,
			SeriesID:    seriesUUID,
			Description: `The Pink Panther animated shorts produced between December 18, 1964 and February 1, 1980 by DePatie-Freleng Enterprises (DFE Films).`, IsVIP: true,
			UploadAt: time.Now(), Url: "https://archive.org/download/ThePinkPanther-cartoons/The%20Pink%20Panther%20in%20-An%20Ounce%20of%20Pink.mp4",
			Thumbnail: "https://archive.org/services/img/ThePinkPanther-cartoons", Genre: AnimationUUID.String(), View: 240197},
		{ID: uuid.New(), Title: "The Pink Panther", Year: 1964,
			SeriesID:    seriesUUID,
			Description: `The Pink Panther animated shorts produced between December 18, 1964 and February 1, 1980 by DePatie-Freleng Enterprises (DFE Films).`, IsVIP: true,
			UploadAt: time.Now(), Url: "https://archive.org/download/ThePinkPanther-cartoons/The%20Pink%20Panther%20in%20-Bobolink%20Pink.mp4",
			Thumbnail: "https://archive.org/services/img/ThePinkPanther-cartoons", Genre: AnimationUUID.String(), View: 240197},
		{ID: uuid.New(), Title: "The Pink Panther", Year: 1964,
			SeriesID:    seriesUUID,
			Description: `The Pink Panther animated shorts produced between December 18, 1964 and February 1, 1980 by DePatie-Freleng Enterprises (DFE Films).`, IsVIP: true,
			UploadAt: time.Now(), Url: "https://archive.org/download/ThePinkPanther-cartoons/The%20Pink%20Panther%20in%20-Bully%20for%20Pink.mp4",
			Thumbnail: "https://archive.org/services/img/ThePinkPanther-cartoons", Genre: AnimationUUID.String(), View: 240197},
		{ID: uuid.New(), Title: "The Pink Panther", Year: 1964,
			SeriesID:    seriesUUID,
			Description: `The Pink Panther animated shorts produced between December 18, 1964 and February 1, 1980 by DePatie-Freleng Enterprises (DFE Films).`, IsVIP: true,
			UploadAt: time.Now(), Url: "https://archive.org/download/ThePinkPanther-cartoons/The%20Pink%20Panther%20in%20-Cat%20and%20the%20Pinkstalk.mp4",
			Thumbnail: "https://archive.org/services/img/ThePinkPanther-cartoons", Genre: AnimationUUID.String(), View: 240197},
	}

	for _, data := range dataSeries {
		var existingData models.Series
		result := db.Where("url = ?", data.Url).First(&existingData)
		if result.Error != nil && result.Error.Error() == gorm.ErrRecordNotFound.Error() {
			if err := db.Create(&data).Error; err != nil {
				log.Fatal("Error inserting data '%s': %v\n", data.Title, err)
			} else {
				fmt.Println(data.ID)
				log.Info("data '%s' inserted successfully.\n", data.Title)
			}
		}
	}
}
