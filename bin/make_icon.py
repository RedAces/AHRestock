import math, sys
from PIL import Image, ImageDraw, ImageFilter, ImageChops

S = 2048  # supersampled canvas
out_dir = sys.argv[1]


def radial(size, inner, outer, center=(0.5, 0.42), radius=0.75):
    img = Image.new("RGB", (size, size))
    px = img.load()
    cx, cy = center[0] * size, center[1] * size
    r = radius * size
    for y in range(size):
        for x in range(size):
            t = min(1.0, math.hypot(x - cx, y - cy) / r)
            px[x, y] = tuple(int(inner[i] + (outer[i] - inner[i]) * t) for i in range(3))
    return img


def vgrad(w, h, top, bottom):
    img = Image.new("RGB", (w, h))
    d = ImageDraw.Draw(img)
    for y in range(h):
        t = y / max(1, h - 1)
        d.line([(0, y), (w, y)], fill=tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3)))
    return img


def mask_from(draw_fn):
    m = Image.new("L", (S, S), 0)
    draw_fn(ImageDraw.Draw(m))
    return m


# --- background: dark arcane blue, rounded square ---
bg = radial(256, (40, 62, 110), (8, 12, 26)).resize((S, S), Image.BICUBIC)
canvas = Image.new("RGBA", (S, S), (0, 0, 0, 0))
corner = int(S * 0.16)
body_mask = mask_from(lambda d: d.rounded_rectangle([0, 0, S - 1, S - 1], corner, fill=255))
canvas.paste(bg, (0, 0), body_mask)

# --- gold frame ---
gold = vgrad(S, S, (255, 226, 140), (150, 96, 30))
frame_w = int(S * 0.045)
frame_mask = mask_from(lambda d: (
    d.rounded_rectangle([0, 0, S - 1, S - 1], corner, fill=255),
    d.rounded_rectangle([frame_w, frame_w, S - 1 - frame_w, S - 1 - frame_w], corner - frame_w, fill=0),
))
canvas.paste(gold, (0, 0), frame_mask)
# thin dark inner line for bevel
inner_line = mask_from(lambda d: d.rounded_rectangle(
    [frame_w, frame_w, S - 1 - frame_w, S - 1 - frame_w], corner - frame_w, outline=255, width=int(S * 0.008)))
canvas.paste((40, 24, 6), (0, 0), inner_line)

# --- restock arrow ring (gold) ---
cx, cy = S * 0.5, S * 0.53
R = S * 0.355
ring_w = int(S * 0.06)
start, end = 120, 400  # degrees, clockwise from 3 o'clock
ring = mask_from(lambda d: d.arc([cx - R, cy - R, cx + R, cy + R], start, end, fill=255, width=ring_w))
# arrowhead at the end of the arc, pointing clockwise
a = math.radians(end)
rm = R - ring_w / 2
tip_c = (cx + rm * math.cos(a), cy + rm * math.sin(a))
tang = (-math.sin(a), math.cos(a))
norm = (math.cos(a), math.sin(a))
hl, hw = S * 0.12, S * 0.10
head = [
    (tip_c[0] + tang[0] * hl, tip_c[1] + tang[1] * hl),
    (tip_c[0] + norm[0] * hw, tip_c[1] + norm[1] * hw),
    (tip_c[0] - norm[0] * hw, tip_c[1] - norm[1] * hw),
]
ImageDraw.Draw(ring).polygon(head, fill=255)

# soft shadow under ring, then the ring itself
shadow = ring.filter(ImageFilter.GaussianBlur(S * 0.012))
canvas.paste((0, 0, 0), (int(S * 0.008), int(S * 0.012)), shadow.point(lambda v: int(v * 0.7)))
canvas.paste(vgrad(S, S, (255, 236, 160), (196, 128, 36)), (0, 0), ring)

# --- potion flask ---
fx, fy = S * 0.5, S * 0.60   # bulb centre
fr = S * 0.20                # bulb radius
neck_w, neck_top = S * 0.11, S * 0.30
glass = mask_from(lambda d: (
    d.ellipse([fx - fr, fy - fr, fx + fr, fy + fr], fill=255),
    d.rounded_rectangle([fx - neck_w / 2, neck_top, fx + neck_w / 2, fy - fr * 0.6], int(S * 0.015), fill=255),
))

# outer glow behind the flask
glow = glass.filter(ImageFilter.GaussianBlur(S * 0.05))
canvas.paste((80, 255, 170), (0, 0), glow.point(lambda v: int(v * 0.55)))

# dark glass outline
outline = glass.filter(ImageFilter.MaxFilter(int(S * 0.02) | 1))
canvas.paste((14, 22, 34), (0, 0), outline)
# glass body (pale, translucent look)
canvas.paste((150, 190, 210), (0, 0), glass.point(lambda v: int(v * 0.55)))

# liquid: lower part of the bulb
liquid_top = fy - fr * 0.15
liquid = ImageChops.multiply(
    glass, mask_from(lambda d: d.rectangle([0, liquid_top, S, S], fill=255)))
liquid = ImageChops.multiply(liquid, mask_from(
    lambda d: d.ellipse([fx - fr * 0.9, fy - fr * 0.9, fx + fr * 0.9, fy + fr * 0.9], fill=255)))
canvas.paste(vgrad(S, S, (120, 255, 190), (10, 120, 80)), (0, 0), liquid)
# liquid surface highlight
surf = mask_from(lambda d: d.ellipse(
    [fx - fr * 0.86, liquid_top - S * 0.018, fx + fr * 0.86, liquid_top + S * 0.018], fill=255))
canvas.paste((200, 255, 225), (0, 0), ImageChops.multiply(surf, glass))
# bubbles
bubbles = mask_from(lambda d: [
    d.ellipse([fx + dx * S - r * S, fy + dy * S - r * S, fx + dx * S + r * S, fy + dy * S + r * S], fill=255)
    for dx, dy, r in [(-0.06, 0.07, 0.022), (0.05, 0.03, 0.015), (0.01, 0.12, 0.012)]])
canvas.paste((210, 255, 230), (0, 0), bubbles)

# glass shine
shine = mask_from(lambda d: d.arc(
    [fx - fr * 0.72, fy - fr * 0.72, fx + fr * 0.72, fy + fr * 0.72], 200, 255, fill=255, width=int(S * 0.025)))
canvas.paste((255, 255, 255), (0, 0), shine.filter(ImageFilter.GaussianBlur(S * 0.004)))
neck_shine = mask_from(lambda d: d.rectangle(
    [fx - neck_w * 0.32, neck_top + S * 0.03, fx - neck_w * 0.18, fy - fr * 0.75], fill=255))
canvas.paste((255, 255, 255), (0, 0), neck_shine.point(lambda v: int(v * 0.8)))

# cork
cork_w, cork_h = neck_w * 1.25, S * 0.07
cork = mask_from(lambda d: d.rounded_rectangle(
    [fx - cork_w / 2, neck_top - cork_h * 0.75, fx + cork_w / 2, neck_top + cork_h * 0.25], int(S * 0.018), fill=255))
canvas.paste((14, 22, 34), (0, 0), cork.filter(ImageFilter.MaxFilter(int(S * 0.014) | 1)))
canvas.paste(vgrad(S, S, (200, 140, 80), (120, 70, 30)), (0, 0), cork)

# clip everything to the rounded square
canvas.putalpha(ImageChops.multiply(canvas.getchannel("A"), body_mask))

# --- exports ---
canvas.resize((400, 400), Image.LANCZOS).save(f"{out_dir}/icon_curseforge.png")
canvas.resize((1024, 1024), Image.LANCZOS).save(f"{out_dir}/icon_preview_1024.png")
# WoW wants power-of-two textures; TGA with alpha, uncompressed
canvas.resize((64, 64), Image.LANCZOS).save(f"{out_dir}/icon.tga", compression=None)
print("ok")
