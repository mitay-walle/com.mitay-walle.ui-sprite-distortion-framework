using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

public class UVScrollEffect : BaseMeshEffect
{
	[SerializeField] private Vector2 _scroll = new Vector2(1, 1);
	[SerializeField] private bool _playEditor;
	private Vector2 _scrollDelta;

	protected override void OnEnable()
	{
		base.OnEnable();
#if UNITY_EDITOR
        EditorApplication.update -= Repaint;
        EditorApplication.update += Repaint;
#endif
	}

	protected override void OnDisable()
	{
		base.OnDisable();
#if UNITY_EDITOR
        EditorApplication.update -= Repaint;
#endif
	}

	public override void ModifyMesh(VertexHelper vh)
	{
		if (!IsActive()) return;
		if (!_playEditor || Application.isPlaying) return;

		int vertCount = vh.currentVertCount;

		_scrollDelta = _scroll * Time.time;

		UIVertex vert = new UIVertex();

		for (var i = 0; i < vertCount; i++)
		{
			vh.PopulateUIVertex(ref vert, i);
#if UNITY_2020_2_OR_NEWER
                vert.uv0 += (Vector4)_scrollDelta;
#else
			vert.uv0 += scrollDelta;
#endif
			vh.SetUIVertex(vert, i);
		}
	}

	private void Update()
	{
		graphic.SetVerticesDirty();
	}

#if UNITY_EDITOR
        private void Repaint()
        {
            if (!_playEditor || Application.isPlaying) return;
            EditorApplication.QueuePlayerLoopUpdate();
            graphic.SetVerticesDirty();
        }
#endif
}