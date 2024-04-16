package main

import (
	"context"
	"database/sql"

	"github.com/aleroxac/goexpert-sqlc/internal/db"
	_ "github.com/go-sql-driver/mysql"
	"github.com/google/uuid"
)

func main() {
	ctx := context.Background()
	dbConn, err := sql.Open("mysql", "root:root@tcp(localhost:3306)/courses")
	if err != nil {
		panic(err)
	}
	defer dbConn.Close()

	queries := db.New(dbConn)

	// ---------- CREATE
	cat1_id := uuid.New().String()
	err = queries.CreateCategory(ctx, db.CreateCategoryParams{
		ID:          cat1_id,
		Name:        "cat1",
		Description: sql.NullString{String: "cat1", Valid: true},
	})
	if err != nil {
		panic(err)
	}

	cat2_id := uuid.New().String()
	err = queries.CreateCategory(ctx, db.CreateCategoryParams{
		ID:          cat2_id,
		Name:        "cat2",
		Description: sql.NullString{String: "cat2", Valid: true},
	})
	if err != nil {
		panic(err)
	}

	// ---------- GET:before
	cat2_before, err := queries.GetCategory(ctx, cat2_id)
	if err != nil {
		panic(err)
	}
	println("cat2[before]:", cat2_before.ID, cat2_before.Name, cat2_before.Description.String)

	// ---------- UPDATE
	err = queries.UpdateCategory(ctx, db.UpdateCategoryParams{
		ID:          cat2_id,
		Name:        "cat2:frontend",
		Description: sql.NullString{String: "cat2:nodejs", Valid: true},
	})
	if err != nil {
		panic(err)
	}

	// ---------- GET:after
	cat2_after, err := queries.GetCategory(ctx, cat2_id)
	if err != nil {
		panic(err)
	}
	println("cat2[after]:", cat2_after.ID, cat2_after.Name, cat2_after.Description.String)

	// ---------- DELETE
	err = queries.DeleteCategory(ctx, cat2_id)
	if err != nil {
		panic(err)
	}

	// ---------- LIST
	categories, err := queries.ListCategories(ctx)
	if err != nil {
		panic(err)
	}
	for _, category := range categories {
		println(category.ID, category.Name, category.Description.String)
	}
}
