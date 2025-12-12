import type { MiddlewareHandler } from 'astro';

/**
 * Security Headers Middleware
 * Adds security headers to all responses
 */
export const onRequest: MiddlewareHandler = async (context, next) => {
	// Get the response
	const response = await next();

	// Add security headers
	response.headers.set('X-Frame-Options', 'DENY');
	response.headers.set('X-Content-Type-Options', 'nosniff');
	response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin');
	
	// HSTS (HTTP Strict Transport Security)
	// GitHub Pages already handles this, but we can reinforce it
	response.headers.set(
		'Strict-Transport-Security',
		'max-age=31536000; includeSubDomains; preload'
	);

	// CSP (Content Security Policy)
	// Basic policy - can be customized based on your needs
	response.headers.set(
		'Content-Security-Policy',
		"default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self';"
	);

	return response;
};

