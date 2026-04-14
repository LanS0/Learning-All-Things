package routes

import (
	"backend/app/controllers/user"
	"backend/app/controllers/video"
	"backend/middleware"

	"github.com/gofiber/fiber/v2"
)

func SetupRoutes(a *fiber.App) {

	api := a.Group("/api")

	api.Get("/recent", middleware.DeserializeUser, video.Recent)
	api.Get("/like", middleware.DeserializeUser, video.Like)

	apiVideo := api.Group("/video")
	apiVideo.Get("/home", middleware.DeserializeUser, video.VideoHome)
	apiVideo.Get("/search", middleware.DeserializeUser, video.VideoSearch)
	apiVideo.Get("/:id", middleware.DeserializeUser, video.VideosByID)

	apiSeries := api.Group("/series")
	apiSeries.Get("/", middleware.DeserializeUser, video.GetSeries)
	apiSeries.Get("/:id", middleware.DeserializeUser, video.GetSeriesByID)

	apiTv := api.Group("/tv")
	apiTv.Get("/", middleware.DeserializeUser, video.GetTV)
	apiTv.Get("/:id", middleware.DeserializeUser, video.GetTVByID)

	apiUser := api.Group("/user")
	apiUser.Post("/login", user.Login)
	apiUser.Post("/register", user.Register)
	apiUser.Post("/changePassword", middleware.DeserializeUser, user.ChangePassword)
	apiUser.Post("/changeName", middleware.DeserializeUser, user.ChangeName)
}
