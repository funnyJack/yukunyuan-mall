package com.yukunyuan.mall.health

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api")
class HealthController {

	/** 给 Flutter 端做连通性探测：GET /api/health */
	@GetMapping("/health")
	fun health(): Map<String, String> = mapOf(
		"status" to "ok",
		"service" to "mall-backend",
	)
}
