package com.yukunyuan.mall.product

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.Id
import jakarta.persistence.PrePersist
import jakarta.persistence.PreUpdate
import jakarta.persistence.Table
import java.time.Instant
import java.util.UUID

/**
 * 商品实体。
 *
 * 金额统一用「分」存 `Long`，与 Flutter 端 `priceCents` 对应，避免浮点误差。
 * 主键用 UUID 字符串，前端 `Product.id` 正是 `String`。
 */
@Entity
@Table(name = "products")
class Product(
	@Id
	@Column(length = 36)
	var id: String = UUID.randomUUID().toString(),

	@Column(nullable = false, length = 30)
	var title: String = "",

	@Column(nullable = false, length = 200)
	var description: String = "",

	@Column(name = "price_cents", nullable = false)
	var priceCents: Long = 0,

	@Enumerated(EnumType.STRING)
	@Column(nullable = false, length = 16)
	var category: ProductCategory = ProductCategory.OTHER,

	@Column(name = "seller_name", nullable = false, length = 30)
	var sellerName: String = "",

	@Column(nullable = false)
	var stock: Int = 0,

	@Column(name = "created_at", nullable = false, updatable = false)
	var createdAt: Instant = Instant.now(),

	@Column(name = "updated_at", nullable = false)
	var updatedAt: Instant = Instant.now(),
) {
	@PrePersist
	fun onPrePersist() {
		val now = Instant.now()
		if (id.isBlank()) id = UUID.randomUUID().toString()
		createdAt = now
		updatedAt = now
	}

	@PreUpdate
	fun onPreUpdate() {
		updatedAt = Instant.now()
	}
}
