package com.yukunyuan.mall.product

import org.springframework.boot.ApplicationArguments
import org.springframework.boot.ApplicationRunner
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty
import org.springframework.stereotype.Component

/**
 * 首次启动时写入与 Flutter 端 `kMockProducts` 一致的演示数据，方便直接联调。
 *
 * 库里已有商品不会重复写；生产环境可通过 `app.seed.enabled=false` 关闭。
 */
@Component
@ConditionalOnProperty(name = ["app.seed.enabled"], havingValue = "true", matchIfMissing = true)
class ProductSeeder(
	private val repository: ProductRepository,
) : ApplicationRunner {

	override fun run(args: ApplicationArguments) {
		if (repository.count() > 0) return
		repository.saveAll(SEED_PRODUCTS)
	}

	private companion object {
		val SEED_PRODUCTS: List<Product> = listOf(
			product("p1", "手工皂礼盒（三块装）", "冷制皂，橄榄油打底，送人自用都合适。每块约 90g，共三块。", 6800, ProductCategory.HANDMADE, "阿梅的小铺", 12),
			product("p2", "现烤黄油曲奇 250g", "当天现烤，动物黄油，无添加剂。下单后两天内发货。", 3990, ProductCategory.FOOD, "烘焙小站", 30),
			product("p3", "二手富士 X100V 相机", "自用机身，快门约 8000 次，带原装电池和腕带，功能正常。", 899900, ProductCategory.DIGITAL, "老周相机", 1),
			product("p4", "手织羊毛围巾", "纯羊毛手织，宽 30cm 长 180cm，可机洗低温。", 12900, ProductCategory.CLOTHING, "阿梅的小铺", 5),
			product("p5", "手捏陶瓷马克杯", "粗陶手作，容量约 350ml，每只釉色略有不同。", 5900, ProductCategory.HOME, "陶土记", 8),
			product("p6", "散养土鸡蛋 30 枚", "山脚下散养，当天拾蛋，泡沫箱加冰袋顺丰发出。", 4550, ProductCategory.FOOD, "山脚下的农场", 20),
			product("p7", "复古机械键盘（已售罄）", "青轴 87 键，配原装键帽，已售出，留作展示。", 32000, ProductCategory.DIGITAL, "老周相机", 0),
			product("p8", "亚麻桌布 140×180", "水洗亚麻，天然米色，边角手工锁边。", 8800, ProductCategory.HOME, "陶土记", 6),
			product("p9", "手绘帆布包", "手工绘制图案，每个都不一样，可装 A4 文件和笔记本电脑。", 7500, ProductCategory.HANDMADE, "小满手作", 9),
			product("p10", "二手轻量登山包 45L", "用过两次，背负系统完好，适合两三天的短线徒步。", 26000, ProductCategory.OTHER, "户外老李", 2),
			product("p11", "棉麻衬衫（米白）", "宽松版型，透气棉麻，男女同款，尺码 S/M/L 可备注。", 15900, ProductCategory.CLOTHING, "小满手作", 4),
			product("p12", "自制辣椒酱 280g", "自家小锅慢炒，无防腐剂，开封后冷藏，一个月内吃完。", 2500, ProductCategory.FOOD, "山脚下的农场", 15),
		)

		fun product(
			id: String,
			title: String,
			description: String,
			priceCents: Long,
			category: ProductCategory,
			sellerName: String,
			stock: Int,
		): Product = Product(
			id = id,
			title = title,
			description = description,
			priceCents = priceCents,
			category = category,
			sellerName = sellerName,
			stock = stock,
		)
	}
}
