package com.yukunyuan.mall.config

import org.springframework.context.annotation.Configuration
import org.springframework.web.servlet.config.annotation.CorsRegistry
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer

/**
 * 开发期跨域配置。
 *
 * Flutter Web 调试时端口是随机的，所以放开所有来源；上线前应改成固定域名。
 */
@Configuration
class WebConfig : WebMvcConfigurer {

	override fun addCorsMappings(registry: CorsRegistry) {
		registry
			.addMapping("/api/**")
			.allowedOriginPatterns("*")
			.allowedMethods("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS")
			.allowedHeaders("*")
			.maxAge(3600)
	}
}
