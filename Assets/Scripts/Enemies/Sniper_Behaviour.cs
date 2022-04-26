using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Sniper_Behaviour : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        GameObject player = UtilsGyromitra.FindInstanceWithinRadius(this.gameObject, "Player", 5.0f);
        if (player != null)
        {
            print(player.tag);
        }
    }
}
