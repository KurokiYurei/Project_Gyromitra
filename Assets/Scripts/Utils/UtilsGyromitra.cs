using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class UtilsGyromitra
{

    /// <summary>
    /// Search if the tag exists in Unity
    /// </summary>
    /// <param name="nameOfTheTag"></param>
    /// <returns> 
    /// Returns an empty string if not found in the tag list 
    /// </returns>
    public static string SearchForTag(string nameOfTheTag)
    {
        string result = "";

        for (int i = 0; i < UnityEditorInternal.InternalEditorUtility.tags.Length; i++)
        {

            if (UnityEditorInternal.InternalEditorUtility.tags[i].Contains(nameOfTheTag))
            {
                result = UnityEditorInternal.InternalEditorUtility.tags[i];
            }
        }

        return result;
    }
}
