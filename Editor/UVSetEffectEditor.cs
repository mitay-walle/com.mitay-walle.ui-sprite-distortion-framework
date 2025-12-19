using UnityEditor;
using UnityEngine;

namespace mitaywalle.UI.Editor
{
	[CanEditMultipleObjects]
	[CustomEditor(typeof(UVSetEffect))]
	public class UVSetEffectEditor : UnityEditor.Editor
	{
		SerializedProperty _set0, _uv0, _labels0;
		SerializedProperty _set1, _uv1, _labels1;
		SerializedProperty _set2, _uv2, _labels2;
		SerializedProperty _set3, _uv3, _labels3;

		void OnEnable()
		{
			_set0 = serializedObject.FindProperty("_set0UV");
			_uv0 = serializedObject.FindProperty("_uv0");
			_labels0 = serializedObject.FindProperty("_uv0Labels");

			_set1 = serializedObject.FindProperty("_set1UV");
			_uv1 = serializedObject.FindProperty("_uv1");
			_labels1 = serializedObject.FindProperty("_uv1Labels");

			_set2 = serializedObject.FindProperty("_set2UV");
			_uv2 = serializedObject.FindProperty("_uv2");
			_labels2 = serializedObject.FindProperty("_uv2Labels");

			_set3 = serializedObject.FindProperty("_set3UV");
			_uv3 = serializedObject.FindProperty("_uv3");
			_labels3 = serializedObject.FindProperty("_uv3Labels");
		}

		public override void OnInspectorGUI()
		{
			serializedObject.Update();

			DrawUVBlock("UV0", _set0, _uv0, _labels0);
			DrawUVBlock("UV1", _set1, _uv1, _labels1);
			DrawUVBlock("UV2", _set2, _uv2, _labels2);
			DrawUVBlock("UV3", _set3, _uv3, _labels3);

			serializedObject.ApplyModifiedProperties();
		}

		private void DrawUVBlock(string title, SerializedProperty toggle, SerializedProperty uv, SerializedProperty labels)
		{
			EditorGUILayout.BeginHorizontal();

			toggle.boolValue = EditorGUILayout.ToggleLeft(title, toggle.boolValue, GUILayout.Width(70));

			if (toggle.boolValue)
				DrawVector4WithLabels(uv, labels);

			EditorGUILayout.EndHorizontal();
		}

		private void DrawVector4WithLabels(SerializedProperty vec, SerializedProperty labels)
		{
			EditorGUILayout.BeginHorizontal();

			float old = EditorGUIUtility.labelWidth;
			EditorGUIUtility.labelWidth = 14;

			for (int i = 0; i < 4; i++)
			{
				EditorGUILayout.BeginVertical(GUILayout.Width(60));

				EditorGUI.BeginChangeCheck();
				string label = EditorGUILayout.TextField(labels.GetArrayElementAtIndex(i).stringValue, EditorStyles.label);
				if (EditorGUI.EndChangeCheck())
					labels.GetArrayElementAtIndex(i).stringValue = label;

				vec.vector4Value = SetComponent(vec.vector4Value, i,
					EditorGUILayout.FloatField(" ", GetComponent(vec.vector4Value, i)));

				EditorGUILayout.EndVertical();
			}

			EditorGUIUtility.labelWidth = old;
			EditorGUILayout.EndHorizontal();
		}

		private static float GetComponent(Vector4 v, int i) =>
			i switch { 0 => v.x, 1 => v.y, 2 => v.z, _ => v.w };

		private static Vector4 SetComponent(Vector4 v, int i, float value)
		{
			switch (i)
			{
				case 0: v.x = value; break;
				case 1: v.y = value; break;
				case 2: v.z = value; break;
				case 3: v.w = value; break;
			}

			return v;
		}
	}
}