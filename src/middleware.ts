import type { MiddlewareHandler } from 'astro';

/**
 * Security Headers Middleware
 * Adds security headers to all responses
 * 
 * Maintenance Mode: Set MAINTENANCE_MODE=true in .env to enable
 */
export const onRequest: MiddlewareHandler = async (context, next) => {
	// Check for maintenance mode (only in production)
	// Локально (dev) всегда видим блог, онлайн (production) работает Maintenance Mode
	// Включить: установить PUBLIC_MAINTENANCE=true в GitHub Pages environment variables
	// ВРЕМЕННО ВКЛЮЧЕНО: maintenanceMode всегда true в production
	const maintenanceMode = import.meta.env.PROD; // Временно включено - показывать maintenance всегда в production
	
	if (maintenanceMode && !context.url.pathname.startsWith('/maintenance')) {
		// Redirect to maintenance page
		return new Response(null, {
			status: 307,
			headers: {
				Location: '/marketlab-academy/maintenance',
			},
		});
	}

	// Get the response
	const response = await next();

	// Add security headers
	response.headers.set('X-Frame-Options', 'DENY');
	response.headers.set('X-Content-Type-Options', 'nosniff');
	response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin');

	// HSTS (HTTP Strict Transport Security)
	response.headers.set(
		'Strict-Transport-Security',
		'max-age=31536000; includeSubDomains; preload'
	);

	// CSP (Content Security Policy)
	response.headers.set(
		'Content-Security-Policy',
		"default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://www.googletagmanager.com https://www.google-analytics.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https:; font-src 'self' data: https://fonts.gstatic.com; connect-src 'self' https://www.google-analytics.com;"
	);

	return response;
};
