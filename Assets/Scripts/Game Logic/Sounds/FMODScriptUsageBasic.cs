using System.Collections;
using UnityEngine;

public class FMODScriptUsageBasic : MonoBehaviour
{
    private void Update()
    {
        
        if(Input.GetKeyDown(KeyCode.Q))
        {
            FMODUnity.RuntimeManager.PlayOneShot("event:/AUGH", GetComponent<Transform>().position);
        }

        if (Input.GetKeyDown(KeyCode.E))
        {
            FMODUnity.RuntimeManager.PlayOneShot("event:/OOF", GetComponent<Transform>().position);
        }

    }
}
