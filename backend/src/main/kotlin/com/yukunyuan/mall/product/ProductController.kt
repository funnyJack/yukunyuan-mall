package com.yukunyuan.mall.product

import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/products")
class ProductController(
	private val service: ProductService,
) {

	/**
	 * GET /api/products?category=食品&q=相机
	 *
	 * category 传「全部」或留空表示不筛选；q 会在标题、描述、店铺名里模糊匹配。
	 */
	@GetMapping
	fun list(
		@RequestParam(required = false) category: String?,
		@RequestParam(name = "q", required = false) keyword: String?,
	): List<ProductResponse> = service.list(category, keyword)

	@GetMapping("/{id}")
	fun detail(@PathVariable id: String): ProductResponse = service.get(id)

	@PostMapping
	@ResponseStatus(HttpStatus.CREATED)
	fun create(@Valid @RequestBody request: CreateProductRequest): ProductResponse =
		service.create(request)
}
