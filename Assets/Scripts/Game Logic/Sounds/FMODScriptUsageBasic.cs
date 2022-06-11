using System.Collections;
using UnityEngine;

public class FMODScriptUsageBasic : MonoBehaviour
{
    private void Update()
    {
        
        if(Input.GetKeyDown(KeyCode.Q))
        {
            FMODUnity.RuntimeManager.PlayOneShot("event:/3 - Click", GetComponent<Transform>().position);
        }

        if (Input.GetKeyDown(KeyCode.E))
        {
            FMODUnity.RuntimeManager.PlayOneShot("event:/10 - So de arc tensat", GetComponent<Transform>().position);
        }

    }
}
