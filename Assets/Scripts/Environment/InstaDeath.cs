using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InstaDeath : MonoBehaviour
{

    private CharacterHP m_player;

    private void OnTriggerEnter(Collider other)
    {
        m_player = other.transform.GetComponent<CharacterHP>();
        m_player.Damage(100f);
    }
}
