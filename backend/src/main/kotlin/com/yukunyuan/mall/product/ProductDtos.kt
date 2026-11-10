package com.yukunyuan.mall.product

import jakarta.validation.constraints.Max
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.PositiveOrZero
import jakarta.validation.constraints.Size

/**
 * 返回给 Flutter 的商品 JSON，字段名与 `lib/models/product.dart` 的 `Product.fromJson` 对齐。
 */
data class ProductResponse(
	val id: String,
	val title: String,
	val description: String,
	val priceCents: Long,
	val category: String,
	val sellerName: String,
	val stock: Int,
)

fun Product.toResponse(): ProductResponse = ProductResponse(
	id = id,
	title = title,
	description = description,
	priceCents = priceCents,
	category = category.label,
	sellerName = sellerName,
	stock = stock,
)

/**
 * 上架请求体。
 *
 * 价格传「分」（例如 68.00 元传 6800）；0 表示「面议」，与前端约定一致。
 * 库存不传默认 1（一件），后续接库存管理时再扩展。
 */
data class CreateProductRequest(
	@field:NotBlank(message = "商品名称不能为空")
	@field:Size(min = 2, max = 30, message = "商品名称需要 2-30 个字")
	val title: String,

	@field:PositiveOrZero(message = "价格不能为负数")
	@field:Max(value = 100_000_000L, message = "价格不能超过 1,000,000 元")
	val priceCents: Long,

	val category: ProductCategory,

	@field:Size(max = 200, message = "商品描述最多 200 个字")
	val description: String = "",

	@field:Size(max = 30, message = "店铺名称最多 30 个字")
	val sellerName: String = "",

	@field:PositiveOrZero(message = "库存不能为负数")
	val stock: Int = 1,
)
