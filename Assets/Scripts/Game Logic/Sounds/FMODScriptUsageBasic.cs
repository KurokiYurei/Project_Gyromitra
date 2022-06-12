using System.Collections;
using UnityEngine;
using FMODUnity;

public class FMODScriptUsageBasic : MonoBehaviour
{
    public static FMODScriptUsageBasic Instance;

    private void Awake()
    {
        Instance = this;
    }
    private void Update()
    {

        if (Input.GetKeyDown(KeyCode.Q))
        {
            FMODUnity.RuntimeManager.PlayOneShot("event:/UI/1 - Pasar por encima", GetComponent<Transform>().position);
        }

        if (Input.GetKeyDown(KeyCode.E))
        {
            FMODUnity.RuntimeManager.PlayOneShot("event:/Enemics/7 - Atac bazooka", GetComponent<Transform>().position);
        }

    }

    public void ExecuteSound(string soundPath, Transform transform)
    {
        FMODUnity.RuntimeManager.PlayOneShot(soundPath, transform.position);
    }

}
