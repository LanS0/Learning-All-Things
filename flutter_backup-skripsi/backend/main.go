package main

import (
	"io/ioutil"
	"os"

	"backend/app/controllers/common"
	"backend/database"
	"backend/routes"

	_ "backend/docs"

	fiberSwagger "github.com/arsmn/fiber-swagger/v2"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/recover"
)

func main() {
	common.Init(ioutil.Discard, os.Stdout, os.Stdout, os.Stderr)

	// Fiber instance
	app := fiber.New()

	// Middleware
	app.Use(recover.New())
	app.Use(cors.New())

	// Connect to the Database
	database.ConnectDB()

	// Routes
	app.Get("/swagger/*", fiberSwagger.HandlerDefault) // default
	routes.SetupRoutes(app)

	app.Get("/", func(c *fiber.Ctx) error {
		err := c.SendString("project-film v1.2.0")
		return err
	})

	app.Use(func(c *fiber.Ctx) error {
		return c.SendStatus(404)
	})

	// MIGRATIONS
	// migration.SeedMaster()

	port := common.Port
	if port == "" {
		port = "7888"
	}

	err := app.Listen(":" + port)
	if err != nil {
		common.Error.Printf("fiber.Listen failed %s", err)
	}

}
