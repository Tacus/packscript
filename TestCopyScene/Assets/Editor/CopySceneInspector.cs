using UnityEngine;
using System.Collections;
using UnityEditor;


[CustomEditor(typeof(CopySceneHandler))]
public class CopySceneInspector : Editor
{


	int selected = 0;
	public override void OnInspectorGUI()
	{
		base.OnInspectorGUI(); 

		//		(EnumList)EditorGUILayout.EnumPopup("EnumPopup", enumValue);
		EditorGUILayout.TextField("地图路径","Assets/Resource/Script/FrameWork/Config/Table_Map.txt",EditorStyles.textField);
		CopySceneHandler obj = target as CopySceneHandler;
		string [] list = {"Studio","TF","Release"};
		selected = EditorGUILayout.Popup("拷贝分支",selected,list,EditorStyles.popup);
		if (GUILayout.Button("开始拷贝"))  
		{  
			CopySceneHandler tar = target as CopySceneHandler;
		}
	}
}

