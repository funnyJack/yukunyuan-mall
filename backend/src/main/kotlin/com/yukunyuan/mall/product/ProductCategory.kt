package com.yukunyuan.mall.product

import com.fasterxml.jackson.annotation.JsonCreator
import com.fasterxml.jackson.annotation.JsonValue
import com.yukunyuan.mall.common.BadRequestException

/**
 * 商品分类，label 与 Flutter 端 `kCategories` 完全一致。
 *
 * 「全部」只是前端筛选项，不属于任何商品，所以不在这里定义。
 */
enum class ProductCategory(val label: String) {
	FOOD("食品"),
	HOME("家居"),
	DIGITAL("数码"),
	CLOTHING("服饰"),
	HANDMADE("手作"),
	OTHER("其他"),
	;

	/** 序列化成中文分类名，前端直接展示。 */
	@JsonValue
	fun jsonValue(): String = label

	companion object {
		private val BY_LABEL: Map<String, ProductCategory> = entries.associateBy { it.label }

		@JvmStatic
		@JsonCreator
		fun fromLabel(label: String): ProductCategory =
			BY_LABEL[label] ?: throw IllegalArgumentException("未知商品分类：$label")

		/** 查询参数转分类：null、空串和「全部」都表示不筛选。 */
		@JvmStatic
		fun parseFilter(raw: String?): ProductCategory? {
			val value = raw?.trim().orEmpty()
			if (value.isEmpty() || value == "全部") return null
			return BY_LABEL[value] ?: throw BadRequestException("未知商品分类：$value")
		}
	}
}
