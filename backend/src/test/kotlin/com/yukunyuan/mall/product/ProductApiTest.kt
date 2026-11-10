package com.yukunyuan.mall.product

import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import org.springframework.test.web.servlet.setup.MockMvcBuilders
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.context.WebApplicationContext

@SpringBootTest
@Transactional
class ProductApiTest {

	@Autowired
	private lateinit var context: WebApplicationContext

	private lateinit var mockMvc: MockMvc

	@BeforeEach
	fun setUp() {
		mockMvc = MockMvcBuilders.webAppContextSetup(context).build()
	}

	@Test
	fun `列表返回种子商品`() {
		mockMvc.perform(get("/api/products"))
			.andExpect(status().isOk)
			.andExpect(jsonPath("$.length()").value(12))
			.andExpect(jsonPath("$[0].id").isNotEmpty)
			.andExpect(jsonPath("$[0].priceCents").isNumber)
			.andExpect(jsonPath("$[0].category").isString)
	}

	@Test
	fun `按分类筛选`() {
		mockMvc.perform(get("/api/products").param("category", "食品"))
			.andExpect(status().isOk)
			.andExpect(jsonPath("$.length()").value(3))
			.andExpect(jsonPath("$[0].category").value("食品"))
	}

	@Test
	fun `按关键词搜索标题与店铺`() {
		// 商品 p3 标题含「相机」，p7 店铺名含「相机」
		mockMvc.perform(get("/api/products").param("q", "相机"))
			.andExpect(status().isOk)
			.andExpect(jsonPath("$.length()").value(2))
	}

	@Test
	fun `查看商品详情`() {
		mockMvc.perform(get("/api/products/p3"))
			.andExpect(status().isOk)
			.andExpect(jsonPath("$.title").value("二手富士 X100V 相机"))
			.andExpect(jsonPath("$.priceCents").value(899900))
			.andExpect(jsonPath("$.sellerName").value("老周相机"))
	}

	@Test
	fun `商品不存在返回 404`() {
		mockMvc.perform(get("/api/products/not-exists"))
			.andExpect(status().isNotFound)
			.andExpect(jsonPath("$.code").value("PRODUCT_NOT_FOUND"))
	}

	@Test
	fun `上架商品后可以查询到`() {
		val body = """
			{
			  "title": "测试手工饼干",
			  "priceCents": 1999,
			  "category": "食品",
			  "description": "单元测试用",
			  "sellerName": "测试小店",
			  "stock": 3
			}
		""".trimIndent()

		val result = mockMvc.perform(
			post("/api/products").contentType(MediaType.APPLICATION_JSON).content(body),
		)
			.andExpect(status().isCreated)
			.andExpect(jsonPath("$.id").isNotEmpty)
			.andExpect(jsonPath("$.title").value("测试手工饼干"))
			.andExpect(jsonPath("$.priceCents").value(1999))
			.andExpect(jsonPath("$.category").value("食品"))
			.andReturn()

		val json = result.response.getContentAsString(Charsets.UTF_8)
		val id = Regex("\"id\"\\s*:\\s*\"([^\"]+)\"").find(json)?.groupValues?.get(1)
		checkNotNull(id) { "创建响应里没有 id：$json" }

		mockMvc.perform(get("/api/products/$id"))
			.andExpect(status().isOk)
			.andExpect(jsonPath("$.sellerName").value("测试小店"))
	}

	@Test
	fun `筛选时传未知分类返回 400`() {
		mockMvc.perform(get("/api/products").param("category", "不存在的分类"))
			.andExpect(status().isBadRequest)
			.andExpect(jsonPath("$.code").value("BAD_REQUEST"))
	}

	@Test
	fun `未知分类返回 400`() {
		val body = """{"title":"测试商品","priceCents":100,"category":"不存在的分类"}"""
		mockMvc.perform(post("/api/products").contentType(MediaType.APPLICATION_JSON).content(body))
			.andExpect(status().isBadRequest)
			.andExpect(jsonPath("$.code").value("INVALID_REQUEST_BODY"))
	}

	@Test
	fun `名称为空返回校验错误`() {
		val body = """{"title":"","priceCents":100,"category":"食品"}"""
		mockMvc.perform(post("/api/products").contentType(MediaType.APPLICATION_JSON).content(body))
			.andExpect(status().isBadRequest)
			.andExpect(jsonPath("$.code").value("VALIDATION_FAILED"))
			.andExpect(jsonPath("$.fieldErrors.title").isNotEmpty)
	}
}
