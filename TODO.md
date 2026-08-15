# TODO

## Mobile hamburger menu not working

The CSS-only hamburger menu (checkbox hack) does not display correctly on Android phones:
- The checkbox input is visible instead of hidden
- The hamburger icon (☰) does not appear

Possible causes to investigate:
- Phone browser cache serving old CSS
- The `@media (max-width: 767px)` breakpoint may not match the phone's CSS viewport
- The `<label>` element may need different styling for mobile WebKit/Blink
- Test with USB debugging (chrome://inspect) to see which CSS rules apply
