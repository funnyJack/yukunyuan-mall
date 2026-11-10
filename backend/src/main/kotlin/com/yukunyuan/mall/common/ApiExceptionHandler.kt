package com.yukunyuan.mall.common

import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.http.converter.HttpMessageNotReadableException
import org.springframework.web.bind.MethodArgumentNotValidException
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice

@RestControllerAdvice
class ApiExceptionHandler {

	@ExceptionHandler(ProductNotFoundException::class)
	fun handleNotFound(ex: ProductNotFoundException): ResponseEntity<ApiError> =
		ResponseEntity
			.status(HttpStatus.NOT_FOUND)
			.body(ApiError("PRODUCT_NOT_FOUND", ex.message ?: "商品不存在"))

	@ExceptionHandler(BadRequestException::class)
	fun handleBadRequest(ex: BadRequestException): ResponseEntity<ApiError> =
		ResponseEntity
			.badRequest()
			.body(ApiError("BAD_REQUEST", ex.message ?: "请求参数不正确"))

	@ExceptionHandler(MethodArgumentNotValidException::class)
	fun handleValidation(ex: MethodArgumentNotValidException): ResponseEntity<ApiError> {
		val fieldErrors = ex.bindingResult.fieldErrors.associate {
			it.field to (it.defaultMessage ?: "参数不合法")
		}
		return ResponseEntity
			.badRequest()
			.body(ApiError("VALIDATION_FAILED", fieldErrors.values.firstOrNull() ?: "请求参数不正确", fieldErrors))
	}

	@ExceptionHandler(HttpMessageNotReadableException::class)
	fun handleUnreadable(ex: HttpMessageNotReadableException): ResponseEntity<ApiError> =
		ResponseEntity
			.badRequest()
			.body(ApiError("INVALID_REQUEST_BODY", "请求体格式不正确，请检查字段类型与取值"))
}
