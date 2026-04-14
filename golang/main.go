package main

import (
	"fmt"
	"strings"
	"sync"
)

func isAnagram(s string, t string) bool {
	// kode kamu di sini
	stringMap := make(map[string]int)
	stringMap2 := make(map[string]int)

	sString := strings.Split(s, "")
	tString := strings.Split(t, "")

	if len(sString) < len(tString) || len(tString) < len(sString) || len(sString) > len(tString) || len(tString) > len(sString) {
		return false
	}

	for _, val := range sString {
		stringMap[val] += 1
	}

	for _, val := range tString {
		stringMap2[val] += 1
	}

	for _, val := range sString {
		if stringMap[val] < stringMap2[val] || stringMap[val] > stringMap2[val] {
			return false
		}
	}

	return true
}

func twoSum(nums []int, target int) []int {
	// kode kamu di sini
	var dataReturn []int

	for i, val := range nums {
		for j, vals := range nums {
			if val+vals == target {
				return []int{i, j}
			}
		}
	}

	return dataReturn
}

func Goroutine() {
	// Proses 5 angka secara parallel, kumpulkan hasilnya
	nums := []int{1, 2, 3, 4, 5}
	ch := make(chan int, len(nums)) // buffered channel
	var wg sync.WaitGroup

	for _, n := range nums {
		wg.Add(1)
		go func(n int) {
			defer wg.Done()
			ch <- n * 2 // proses lalu kirim ke channel
		}(n)
	}

	// Tutup channel setelah semua goroutine selesai
	go func() {
		wg.Wait()
		close(ch)
	}()

	// Kumpulkan hasil
	for result := range ch {
		fmt.Println(result) // 2, 4, 6, 8, 10 (urutan bisa beda!)
	}
}

func fibonacci(n int) int {
	if n == 1 || n == 0 {
		return n
	}
	return fibonacci(n-1) + fibonacci(n-2)
}

var fib_data = map[int]int64{
	0: 0,
	1: 1,
}

// kalau menggunakan int biasa akan ada overflow integer, dimana batas ada di 2,147,483,647. Sedangkan
// jika menggunakan int64 max 9,223,372,036,854,775,807
func fibonacci_withMaps(n int) int64 {
	if val, status := fib_data[n]; status {
		return val
	}

	fib_data[n] = fibonacci_withMaps(n-1) + fibonacci_withMaps(n-2)
	return fib_data[n]
}

func isPalindrome(n int) bool {

	if n < 10 {
		return true
	}

	initiate := n
	starter := 0

	for n > 0 {
		fmt.Println(starter, n)

		starter = (starter * 10) + (n % 10)
		n /= 10

		fmt.Println(starter, n)
	}

	if starter == initiate {
		return true
	}

	return false
}

func main() {
	// go fmt.Println(fibonacci(20))
	fmt.Println(fibonacci_withMaps(120))
	fmt.Println(fib_data)
}
