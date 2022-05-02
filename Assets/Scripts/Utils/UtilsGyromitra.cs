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

    /// <summary>
    /// Return the normalized value of the position of a float between two others
    /// </summary>
    /// <param name="max">Max value from range</param>
    /// <param name="min">Min value from range</param>
    /// <param name="current">Current value between the 2</param>
    /// <returns>Float normalized of the position</returns>
    public static float NormalizedFloatFromARange(float max, float min, float current)
    {
        return (current - min) / (max - min);
    }

    /// <summary>
    /// Return the inverse normalized value of the position of a float between two others
    /// </summary>
    /// <param name="max">Max value from range</param>
    /// <param name="min">Min value from range</param>
    /// <param name="current">Current value between the 2</param>
    /// <returns>Float inverserd normalized of the position</returns>
    public static float InversedNormalizedFloatFromARange(float max, float min, float current)
    {
        return (max - current) / (max - min);
    }

    /// <summary>
    /// Find and instance of an object wihtin a specific radius
    /// </summary>
    /// <param name="self"></param>
    /// <param name="tag"></param>
    /// <param name="radius"></param>
    /// <returns></returns>
    public static GameObject FindInstanceWithinRadius(GameObject self, string tag, float radius)
    {
        GameObject otherGameObject = GameObject.FindGameObjectWithTag(tag);

        float distance = (otherGameObject.transform.position - self.transform.position).magnitude;

        if (distance <= radius)
        {
            return otherGameObject;
        }
        else
        {
            return null;
        }

    }

    /// <summary>
    /// get a random number between two
    /// </summary>
    /// <param name="number1"></param>
    /// <param name="number2"></param>
    /// <returns></returns>
    public static int RandomNumber(int number1, int number2)
    {
        return Random.Range(number1, number2);
    }

}
