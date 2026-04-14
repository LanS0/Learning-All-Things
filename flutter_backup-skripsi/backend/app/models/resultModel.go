package models

type ResultJSON struct {
	StatusCode string      `json:"status_code"`
	Message    string      `json:"message"`
	Data       interface{} `json:"data"`
}

type ResultLogin struct {
	StatusCode string      `json:"status_code"`
	Message    string      `json:"message"`
	Data       interface{} `json:"data"`
	Token      string      `json:"token"`
}

type ResultPagination struct {
	StatusCode string      `json:"status_code"`
	Message    string      `json:"message"`
	Total      int         `json:"total"`
	Limit      int         `json:"limit"`
	Data       interface{} `json:"data"`
	Current    int         `json:"current"`
	First      int         `json:"first"`
	Last       float64     `json:"last"`
	Next       int         `json:"next"`
	Prev       int         `json:"prev"`
}
