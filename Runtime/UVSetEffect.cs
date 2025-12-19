using UnityEngine;
using UnityEngine.UI;

namespace mitaywalle.UI
{
	public class UVSetEffect : BaseMeshEffect
	{
		[SerializeField] private bool _set0UV;
		[SerializeField] private Vector4 _uv0 = new(1, 1);

		[SerializeField] private bool _set1UV = true;
		[SerializeField] private Vector4 _uv1 = new(1, 1);

		[SerializeField] private bool _set2UV;
		[SerializeField] private Vector4 _uv2 = new(1, 1);

		[SerializeField] private bool _set3UV;
		[SerializeField] private Vector4 _uv3 = new(1, 1);

		[SerializeField, HideInInspector] private string[] _uv0Labels = { "X", "Y", "Z", "W" };
		[SerializeField, HideInInspector] private string[] _uv1Labels = { "X", "Y", "Z", "W" };
		[SerializeField, HideInInspector] private string[] _uv2Labels = { "X", "Y", "Z", "W" };
		[SerializeField, HideInInspector] private string[] _uv3Labels = { "X", "Y", "Z", "W" };

		public override void ModifyMesh(VertexHelper vh)
		{
			if (!IsActive()) return;

			int count = vh.currentVertCount;
			UIVertex vert = new();

			for (int i = 0; i < count; i++)
			{
				vh.PopulateUIVertex(ref vert, i);

				if (_set0UV) vert.uv0 = _uv0;
				if (_set1UV) vert.uv1 = _uv1;
				if (_set2UV) vert.uv2 = _uv2;
				if (_set3UV) vert.uv3 = _uv3;

				vh.SetUIVertex(vert, i);
			}
		}

		public void SetUV2X(float value) => _uv1.x = value;
		public void SetUV2Y(float value) => _uv1.y = value;
	}
}