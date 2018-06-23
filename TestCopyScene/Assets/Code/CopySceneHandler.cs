using UnityEngine;
using System.Collections;
using System.Collections.Generic;


public class CopySceneHandler : MonoBehaviour
{
	public List<string> list = new List<string>();

	[SerializeField]
	private TextAsset _map;

	public TextAsset map {
		set{
			_map = value;
		}
		get{
			return _map;
		}

	}

	void ToStudio()
	{
//		CopySceneToStudio(BranchCommand.GetStudioPath(), "Studio");
	}

	void CopySceneToStudio(string path,string name)
	{

	}
}


