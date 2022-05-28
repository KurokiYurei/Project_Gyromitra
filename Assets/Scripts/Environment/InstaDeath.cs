using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InstaDeath : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        CharacterHP m_component = other.transform.GetComponent<CharacterHP>();
        if(m_component != null ) m_component.Damage(200f);

    }
}
