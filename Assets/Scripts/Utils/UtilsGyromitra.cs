using FMOD.Studio;
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
        string result;

        try
        {
            GameObject.FindGameObjectsWithTag(nameOfTheTag);
            result = nameOfTheTag;
        }
        catch
        {
            result = "";
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

        if (otherGameObject == null)
            return null;

        if (DistanceToTarget(self, otherGameObject) <= radius)
        {
            return otherGameObject;
        }
        else
        {
            return null;
        }
    }

    public static GameObject FindMushroomsWithinRadius(GameObject self, string tag, float radius)
    {
        GameObject[] targets = GameObject.FindGameObjectsWithTag(tag);
        if (targets.Length == 0) return null;

        float dist = 0;
        GameObject closest = targets[0];
        float minDistance = (closest.transform.position - self.transform.position).magnitude;

        for (int i = 1; i < targets.Length; i++)
        {
            dist = (targets[i].transform.position - self.transform.position).magnitude;
            if (dist < minDistance)
            {
                minDistance = dist;
                closest = targets[i];
            }
        }
        if (minDistance < radius) return closest;
        else return null;
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

    /// <summary>
    /// Find the distance of two objects
    /// </summary>
    /// <param name="l_object1"></param>
    /// <param name="l_object2"></param>
    /// <returns></returns>
    public static float DistanceToTarget(GameObject l_object1, GameObject l_object2)
    {
        return (l_object2.transform.position - l_object1.transform.position).magnitude;
    }

    /// <summary>
    /// Sound functions
    /// </summary>
    /// <param name="l_event"></param>
    /// <param name="l_emitterTransform"></param>
    public static void playSound(EventInstance l_event, Transform l_emitterTransform)
    {
        l_event.set3DAttributes(FMODUnity.RuntimeUtils.To3DAttributes(l_emitterTransform));
        l_event.start();
    }

    public static void stopSound(EventInstance l_event)
    {
        l_event.stop(FMOD.Studio.STOP_MODE.ALLOWFADEOUT);
    }

}
