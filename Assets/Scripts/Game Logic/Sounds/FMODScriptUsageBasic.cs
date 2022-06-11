using System.Collections;
using UnityEngine;

public class FMODScriptUsageBasic : MonoBehaviour
{
    private void Update()
    {
        
        if(Input.GetKeyDown(KeyCode.Q))
        {
            FMODUnity.RuntimeManager.PlayOneShot("event:/UI/1 - Pasar por encima", GetComponent<Transform>().position);
        }

        if (Input.GetKeyDown(KeyCode.E))
        {
            FMODUnity.RuntimeManager.PlayOneShot("event:/Enemics/7 - Atac bazooka", GetComponent<Transform>().position);
        }

    }
}
