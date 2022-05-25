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

    private CharacterControllerScript m_player;
    private CharacterHP m_playerHealth;

    private void Awake()
    {
        m_durationVenom = 3f;

        m_venomDamageTimer = 1f;
        m_currentVenomDamageTimer = m_venomDamageTimer;

        m_damage = 5f;

        m_playerIsIn = false;
        m_playerTag = UtilsGyromitra.SearchForTag("Player");

        m_player = GameObject.FindGameObjectWithTag(m_playerTag).GetComponent<CharacterControllerScript>();
        m_playerHealth = m_player.gameObject.GetComponent<CharacterHP>();
    }

    private void OnEnable()
    {
        m_player.OnStopPoison += StopPoison;
    }
    private void OnDisable()
    {
        m_player.OnStopPoison -= StopPoison;
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

        if (m_currentDurationVenom >= 0f)
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
                m_playerHealth.Damage(m_damage);
            }
        } 
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == m_playerTag)
        {
            m_playerIsIn = true;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == m_playerTag)
        {
            m_playerIsIn = false;
        }
    }

    private void StopPoison()
    {
        m_playerIsIn = false;
        m_currentDurationVenom = 0f;
        m_currentVenomDamageTimer = m_venomDamageTimer;
    }
}
