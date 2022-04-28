using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManagerScript : MonoBehaviour
{
    [SerializeField]
    private GameObject m_player;

    private Vector3 m_startPosPlayer;

    private Quaternion m_startRotationPlayer;


    private void Start()
    {
        m_startPosPlayer = m_player.transform.position;
        m_startRotationPlayer = m_player.transform.rotation;
    }

    private void Update()
    {
        if(m_player.transform.GetComponent<CharacterHP>().m_health <= 0f)
        {
            RestartGame();
        }
    }

    private void RestartGame()
    {
        m_player.transform.GetComponent<CharacterController>().enabled = false;
        m_player.transform.position = m_startPosPlayer;
        m_player.transform.rotation = m_startRotationPlayer;
        m_player.transform.GetComponent<CharacterHP>().m_health = 100f;
        m_player.transform.GetComponent<CharacterController>().enabled = true;
    }
}
