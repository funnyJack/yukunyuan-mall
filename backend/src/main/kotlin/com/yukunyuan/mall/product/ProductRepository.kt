package com.yukunyuan.mall.product

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param

interface ProductRepository : JpaRepository<Product, String> {

	/**
	 * 按分类 + 关键词筛选。
	 *
	 * [q] 传入的是已经拼好 `%` 的 like 参数（小写）；为 null 表示不按关键词过滤。
	 */
	@Query(
		"""
		select p from Product p
		where (:category is null or p.category = :category)
		  and (
		    :q is null
		    or lower(p.title) like :q
		    or lower(p.description) like :q
		    or lower(p.sellerName) like :q
		  )
		order by p.createdAt desc, p.id
		""",
	)
	fun search(
		@Param("category") category: ProductCategory?,
		@Param("q") q: String?,
	): List<Product>
}
