using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterHP : MonoBehaviour, IDamagable
{
    public float m_health { get; set; }

    private float m_maxHealth;
    private float m_minHealth;

    private float m_startTimeToRegen;

    [SerializeField]
    private float m_timerToRegen;

    [SerializeField]
    private float m_tickPerSecondHealth;

    private float m_healthPerSecond;

    [SerializeField]
    private UI_Manager m_ui;

    [SerializeField]
    private Material m_quiverShader;

    void Start()
    {
        m_minHealth = 0f;
        m_maxHealth = 100f;

        m_timerToRegen = 2f;
        m_startTimeToRegen = 2f;
        m_healthPerSecond = 10f;
        m_tickPerSecondHealth = 1f;

        m_health = m_maxHealth;
    }

    void Update()
    {
        m_ui.SetHealth(m_health);

        m_quiverShader.SetFloat("_Fill", m_health/100f);

        m_timerToRegen -= Time.deltaTime;

        if (m_timerToRegen <= 0f && m_health <= 100f)
        {
            m_tickPerSecondHealth -= Time.deltaTime;

            if (m_tickPerSecondHealth <= 0f)
            {
                Regen();
                m_tickPerSecondHealth = 1f;
            }
        }
    }

    /// <summary>
    /// Deal damage to the player
    /// </summary>
    /// <param name="damage"></param>
    public void Damage(float damage)
    {
        m_timerToRegen = m_startTimeToRegen;
        m_health -= damage;
        if (m_health <= m_minHealth)
        {
            //gameObject.GetComponent<CharacterControllerScript>().m_gameManager.RestartGame();
            GameManagerScript.m_instance.RestartGame();
        }
    }

    /// <summary>
    /// regen function
    /// </summary>
    public void Regen()
    {
        if(m_health >= m_maxHealth)
        {
            m_health = m_maxHealth;
        }
        else
        {
            m_health += m_healthPerSecond;
        }
    }

    /// <summary>
    /// reset hp of the player
    /// </summary>
    public void ResetHP()
    {
        m_health = m_maxHealth;
    }
}
