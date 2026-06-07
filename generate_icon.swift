#!/usr/bin/env swift
/// Subly 앱 아이콘 생성 스크립트
/// 실행: swift generate_icon.swift  (프로젝트 루트에서)
import CoreGraphics
import CoreText
import ImageIO
import Foundation

func makeIcon(size s: CGFloat) -> CGImage? {
    let n = Int(s)
    guard let ctx = CGContext(
        data: nil, width: n, height: n, bitsPerComponent: 8,
        bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { return nil }

    // ── 1. 보라색 그라디언트 배경 ────────────────────────────────────
    let cs = CGColorSpaceCreateDeviceRGB()
    let grad = CGGradient(
        colorsSpace: cs,
        colors: [
            CGColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 1),
            CGColor(red: 0.46, green: 0.29, blue: 0.64, alpha: 1)
        ] as CFArray,
        locations: [0, 1]
    )!
    ctx.drawLinearGradient(grad,
                           start: CGPoint(x: 0, y: s),
                           end:   CGPoint(x: s, y: 0),
                           options: [])

    // ── 2. 흰색 카드 ────────────────────────────────────────────────
    let cw = s * 0.58, ch = s * 0.38
    let cRect = CGRect(x: (s - cw) / 2, y: (s - ch) / 2, width: cw, height: ch)
    let cPath = CGPath(roundedRect: cRect,
                       cornerWidth: s * 0.065, cornerHeight: s * 0.065,
                       transform: nil)
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
    ctx.addPath(cPath); ctx.fillPath()

    // ── 3. 카드 하단 밴드 + 텍스트 줄 ──────────────────────────────
    ctx.saveGState()
    ctx.addPath(cPath); ctx.clip()
    ctx.setFillColor(CGColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 0.18))
    ctx.fill(CGRect(x: cRect.minX, y: cRect.minY, width: cw, height: ch * 0.26))
    ctx.setFillColor(CGColor(red: 0.4, green: 0.4, blue: 0.55, alpha: 0.15))
    ctx.fill(CGRect(x: cRect.minX + cw*0.10, y: cRect.minY + ch*0.46, width: cw*0.52, height: ch*0.08))
    ctx.fill(CGRect(x: cRect.minX + cw*0.10, y: cRect.minY + ch*0.60, width: cw*0.30, height: ch*0.08))
    ctx.restoreGState()

    // ── 4. 체크마크 뱃지 (카드 우상단) ─────────────────────────────
    let bd = s * 0.225
    let bCX = cRect.maxX - bd * 0.05
    let bCY = cRect.maxY + bd * 0.05
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
    ctx.fillEllipse(in: CGRect(x: bCX - bd/2, y: bCY - bd/2, width: bd, height: bd))

    let r = bd / 2
    let ck = CGMutablePath()
    ck.move(to:    CGPoint(x: bCX - r*0.28, y: bCY))
    ck.addLine(to: CGPoint(x: bCX - r*0.05, y: bCY - r*0.28))
    ck.addLine(to: CGPoint(x: bCX + r*0.32, y: bCY + r*0.30))
    ctx.addPath(ck)
    ctx.setStrokeColor(CGColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 1))
    ctx.setLineWidth(s * 0.026)
    ctx.setLineCap(.round); ctx.setLineJoin(.round)
    ctx.strokePath()

    return ctx.makeImage()
}

func savePNG(_ img: CGImage, to path: String) {
    let url = URL(fileURLWithPath: path)
    guard let dest = CGImageDestinationCreateWithURL(
        url as CFURL, "public.png" as CFString, 1, nil
    ) else { print("✗ 저장 실패: \(path)"); return }
    CGImageDestinationAddImage(dest, img, nil)
    print(CGImageDestinationFinalize(dest) ? "✓ 저장됨: \(path)" : "✗ 실패: \(path)")
}

guard let icon = makeIcon(size: 1024) else { print("아이콘 생성 실패"); exit(1) }
savePNG(icon, to: "Subly/Assets.xcassets/AppIcon.appiconset/AppIcon.png")
print("완료! Xcode에서 Cmd+R 로 빌드하면 아이콘이 적용됩니다.")
