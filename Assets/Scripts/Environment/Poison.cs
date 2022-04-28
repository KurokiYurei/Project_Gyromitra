using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Poison : MonoBehaviour
{

    [SerializeField]
    private float m_currentDurationVenom;
    private float m_durationVenom;

    [SerializeField]
    private float m_currentVenomDamageTimer;
    private float m_venomDamageTimer;

    [SerializeField]
    private float m_damage;

    [SerializeField]
    private bool m_playerIsIn;

    [SerializeField]
    private string m_playerTag;

    private CharacterHP m_player;

    private void Start()
    {
        m_durationVenom = 3f;
        m_currentDurationVenom = m_durationVenom;

        m_venomDamageTimer = 1f;
        m_currentVenomDamageTimer = m_venomDamageTimer;

        m_damage = 5f;

        m_playerIsIn = false;
        m_playerTag = UtilsGyromitra.SearchForTag("Player");
    }

    private void Update()
    {
        
        if (m_playerIsIn)
        {
            m_currentDurationVenom = m_durationVenom;

        } else
        {
            m_currentDurationVenom -= Time.deltaTime;
        }

        if (m_currentDurationVenom >= 0f && m_player != null)
        {
            // venom is active

            if (m_currentVenomDamageTimer >= 0f)
            {
                // timer
                m_currentVenomDamageTimer -= Time.deltaTime;

            } else
            {
                // do dmg
                m_currentVenomDamageTimer = m_venomDamageTimer;
                m_player.Damage(m_damage);
            }


        } else
        {
            // venom run out of time
            m_player = null;
            m_currentDurationVenom = m_durationVenom;
        }


    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == m_playerTag)
        {
            m_playerIsIn = true;
            m_player = other.transform.GetComponent<CharacterHP>();
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == m_playerTag)
        {
            m_playerIsIn = false;
        }
    }

}
