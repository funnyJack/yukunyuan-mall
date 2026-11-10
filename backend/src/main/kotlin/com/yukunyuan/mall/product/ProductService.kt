package com.yukunyuan.mall.product

import com.yukunyuan.mall.common.ProductNotFoundException
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional(readOnly = true)
class ProductService(
	private val repository: ProductRepository,
) {

	fun list(category: String?, keyword: String?): List<ProductResponse> {
		val filter = ProductCategory.parseFilter(category)
		val like = keyword?.trim()?.takeIf { it.isNotEmpty() }?.let { "%${it.lowercase()}%" }
		return repository.search(filter, like).map { it.toResponse() }
	}

	fun get(id: String): ProductResponse =
		repository.findById(id).orElseThrow { ProductNotFoundException(id) }.toResponse()

	@Transactional
	fun create(request: CreateProductRequest): ProductResponse {
		val product = Product(
			title = request.title.trim(),
			description = request.description.trim(),
			priceCents = request.priceCents,
			category = request.category,
			sellerName = request.sellerName.trim().ifEmpty { DEFAULT_SELLER },
			stock = request.stock,
		)
		return repository.save(product).toResponse()
	}

	private companion object {
		const val DEFAULT_SELLER = "匿名店主"
	}
}
