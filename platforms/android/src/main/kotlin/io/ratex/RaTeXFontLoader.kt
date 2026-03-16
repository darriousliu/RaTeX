// RaTeXFontLoader.kt — Load KaTeX fonts for glyph rendering (mirrors iOS RaTeXFontLoader).
//
// GlyphPath from Rust contains placeholder rectangles, not outline paths. Glyphs must be drawn
// with Typeface + Canvas.drawText. Call loadFromAssets() once at app startup (e.g. in Application
// or MainActivity), then RaTeXRenderer will use getTypeface() when drawing.

package io.ratex

import android.content.Context
import android.graphics.Typeface
import java.util.concurrent.ConcurrentHashMap

object RaTeXFontLoader {

    /** KaTeX font IDs (Rust FontId.as_str()) → TTF filename without path. */
    private val fontFileNames = listOf(
        "AMS-Regular" to "KaTeX_AMS-Regular.ttf",
        "Caligraphic-Regular" to "KaTeX_Caligraphic-Regular.ttf",
        "Fraktur-Regular" to "KaTeX_Fraktur-Regular.ttf",
        "Main-Bold" to "KaTeX_Main-Bold.ttf",
        "Main-BoldItalic" to "KaTeX_Main-BoldItalic.ttf",
        "Main-Italic" to "KaTeX_Main-Italic.ttf",
        "Main-Regular" to "KaTeX_Main-Regular.ttf",
        "Math-BoldItalic" to "KaTeX_Math-BoldItalic.ttf",
        "Math-Italic" to "KaTeX_Math-Italic.ttf",
        "SansSerif-Bold" to "KaTeX_SansSerif-Bold.ttf",
        "SansSerif-Italic" to "KaTeX_SansSerif-Italic.ttf",
        "SansSerif-Regular" to "KaTeX_SansSerif-Regular.ttf",
        "Script-Regular" to "KaTeX_Script-Regular.ttf",
        "Size1-Regular" to "KaTeX_Size1-Regular.ttf",
        "Size2-Regular" to "KaTeX_Size2-Regular.ttf",
        "Size3-Regular" to "KaTeX_Size3-Regular.ttf",
        "Size4-Regular" to "KaTeX_Size4-Regular.ttf",
        "Typewriter-Regular" to "KaTeX_Typewriter-Regular.ttf",
    )

    private val cache = ConcurrentHashMap<String, Typeface>()

    /**
     * Load KaTeX fonts from app assets. Call once at startup (e.g. in Application or MainActivity).
     * @param assetPath Path under assets, e.g. "fonts" for assets/fonts/KaTeX_*.ttf
     * @return Number of fonts successfully loaded
     */
    @JvmStatic
    fun loadFromAssets(context: Context, assetPath: String = "fonts"): Int {
        val prefix = assetPath.trimEnd('/')
        var loaded = 0
        for ((fontId, fileName) in fontFileNames) {
            val path = if (prefix.isEmpty()) fileName else "$prefix/$fileName"
            try {
                val typeface = Typeface.createFromAsset(context.assets, path)
                cache[fontId] = typeface
                loaded++
            } catch (_: Exception) {
                // Font file not present — skip
            }
        }
        return loaded
    }

    /**
     * Get cached Typeface for a font ID (e.g. "Main-Regular", "Math-Italic").
     * Returns null if not loaded; Renderer will then draw placeholder.
     */
    @JvmStatic
    fun getTypeface(fontId: String): Typeface? = cache[fontId]

    /** Clear cache (e.g. for tests). */
    @JvmStatic
    fun clear() = cache.clear()
}
