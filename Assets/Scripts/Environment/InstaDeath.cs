using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InstaDeath : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        other.transform.GetComponent<CharacterHP>().Damage(100f);
    }
}
