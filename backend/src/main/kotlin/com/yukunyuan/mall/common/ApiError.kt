package com.yukunyuan.mall.common

/**
 * 统一的错误响应结构，Flutter 端解析失败响应时可按 [code] 做分支。
 *
 * - [fieldErrors] 仅在参数校验失败时返回，key 是字段名，value 是中文提示。
 */
data class ApiError(
	val code: String,
	val message: String,
	val fieldErrors: Map<String, String>? = null,
)

/** 商品不存在，映射为 404。 */
class ProductNotFoundException(id: String) : RuntimeException("商品不存在：$id")

/** 业务参数不合法，映射为 400。 */
class BadRequestException(message: String) : RuntimeException(message)
