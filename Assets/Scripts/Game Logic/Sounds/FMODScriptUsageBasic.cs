using System.Collections;
using UnityEngine;

public class FMODScriptUsageBasic : MonoBehaviour
{
    private void Update()
    {
        
        if(Input.GetKeyDown(KeyCode.Q))
        {
            FMODUnity.RuntimeManager.PlayOneShot("event:/augh", GetComponent<Transform>().position);
        }

        if (Input.GetKeyDown(KeyCode.E))
        {
            FMODUnity.RuntimeManager.PlayOneShot("event:/oof", GetComponent<Transform>().position);
        }

    }
}
