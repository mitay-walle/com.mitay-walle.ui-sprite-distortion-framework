# Unity3d UI Sprite Distortion Framework
Unity3d shader and scripts to make uGUI sprite distortion

[Youtube video with usage example](https://youtu.be/wUtYrXyHBgc)

<img width="1197" height="842" alt="{92CD87F9-7DB7-4390-A26E-059DF54DE9BF}" src="https://github.com/user-attachments/assets/fa28d95b-41f8-4817-8285-ed7f70ae5ed0" />

<img width="587" height="293" alt="{286AC848-2E42-44D6-AA52-8EFADAE9F2FD}" src="https://github.com/user-attachments/assets/d7272eee-b276-4452-ad68-8b6498c6f97b" />

<img width="571" height="459" alt="{C4CE8124-FFDC-4B20-8D0C-711CF90DCFD2}" src="https://github.com/user-attachments/assets/abc0bec4-5f52-484b-8833-fce786799bb7" />

## Features
- Components works with all UI.Graphic Components (Image, RawImage, Custom Graphic, TMPro)
- Component: UVSetEffect
- Renamable xywz vector components (like ParticleSystem.Custom)
- Component: UVScrollEffect
- UI Shader (No TMPro support) with:
- Configurable blending (Alpha, Additive, Multply etc. Separated alpha / rgb blend configuration. 1 material per blend mode and Distortion texture needed)
- Masking supported
- UV Distortion by Texture noise (1 material per different Distortion texture needed)
- UV customized by UVSetEffect (1 material for many distorted graphic components / sprites with different distortion settings)
- UV Swirl Noise Textures in Samples
