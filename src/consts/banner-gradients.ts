// banner-gradients.ts - Библиотека градиентов для баннеров

export const BANNER_GRADIENTS = {
	// Трейдинг - фиолетово-синий
	trading: '135deg, #667eea 0%, #764ba2 100%',
	
	// Криптовалюта - розово-красный
	crypto: '135deg, #f093fb 0%, #f5576c 100%',
	
	// Автоматизация - голубой
	automation: '135deg, #4facfe 0%, #00f2fe 100%',
	
	// Стратегии - зелёный
	strategies: '135deg, #43e97b 0%, #38f9d7 100%',
	
	// Зелёный (основной для блога)
	green: '135deg, #4A9A4A 0%, #2D5F4F 100%',
	
	// Золотой (акцентный)
	gold: '135deg, #F5A623 0%, #FF8C42 100%',
	
	// Тёмный (для серьёзных тем)
	dark: '135deg, #2A2A2A 0%, #1A1A1A 100%',
	
	// По умолчанию
	default: '135deg, #4A9A4A 0%, #2D5F4F 100%',
} as const;

export type BannerGradientKey = keyof typeof BANNER_GRADIENTS;

export const BANNER_ACCENT_COLORS = {
	trading: '#764ba2',
	crypto: '#f5576c',
	automation: '#00f2fe',
	strategies: '#38f9d7',
	green: '#4A9A4A',
	gold: '#F5A623',
	dark: '#4A9A4A',
	default: '#F5A623',
} as const;




